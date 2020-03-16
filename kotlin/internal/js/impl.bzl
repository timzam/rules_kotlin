# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
load(
    "//kotlin/internal:defs.bzl",
    _KT_COMPILER_REPO = "KT_COMPILER_REPO",
    _KtJsInfo = "KtJsInfo",
    _TOOLCHAIN_TYPE = "TOOLCHAIN_TYPE",
)
load(
    "//kotlin/internal/utils:utils.bzl",
    _utils = "utils",
)

# The following kt-js flags are currently not used.
# -Xfriend-modules=<path>
#  -output-postfix <path>     Path to file which will be added to the end of output file
#  -output-prefix <path>      Path to file which will be added to the beginning of output file
#  -source-map-base-dirs <path> Base directories which are used to calculate relative paths to source files in source map
#  -source-map-embed-sources { always, never, inlining }
#                             Embed source files into source map
#  -source-map-prefix         Prefix for paths in a source map
#  -Xtyped-arrays

def kt_js_library_impl(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN_TYPE]

    # meta.js is merged in with the js in the builder. It is declared as it's created at the package level and not in
    # some anonymous directory.
    out_meta = ctx.actions.declare_file(ctx.attr.name + ".meta.js")

    # The Kotlin compiler and intellij infrastructure uses jars and bytecode. The out dir contains bytecode generated by
    # the kotlin compiler. In addition to the js and js.map file a jar is also produced.
    out_dir = ctx.actions.declare_directory(ctx.label.name)

    libraries = depset([d[_KtJsInfo].jar for d in ctx.attr.deps])

    args = _utils.init_args(
        ctx,
        "kt_js_library",
        _utils.derive_module_name(ctx),
    )

    args.add_all(
        "--kotlin_js_passthrough_flags",
        [
            "-source-map",
            "-meta-info",
            "-no-stdlib",  # TODO remove this once the stdlib is not conveyed to node via the deps attribute.
            "-Xmulti-platform",
            "-module-kind",
            ctx.attr.module_kind,
            "-target",
            ctx.attr.js_target,
        ],
    )

    args.add("--output", ctx.outputs.js)
    args.add("--kotlin_js_dir", out_dir.path)
    args.add("--kotlin_output_js_jar", ctx.outputs.jar)
    args.add("--kotlin_output_srcjar", ctx.outputs.srcjar)

    args.add_all("--kotlin_js_libraries", libraries, omit_if_empty = False)
    args.add_all("--sources", ctx.files.srcs)

    inputs, _, input_manifests = ctx.resolve_command(tools = [toolchain.kotlinbuilder, toolchain.kotlin_home])

    ctx.actions.run(
        mnemonic = "KotlinCompile",
        inputs = depset(inputs + ctx.files.srcs, transitive = [libraries]),
        outputs = [
            ctx.outputs.js,
            ctx.outputs.js_map,
            ctx.outputs.jar,
            ctx.outputs.srcjar,
            out_meta,
            out_dir,
        ],
        executable = toolchain.kotlinbuilder.files_to_run.executable,
        execution_requirements = {"supports-workers": "1"},
        arguments = [args],
        progress_message = "Compiling Kotlin to JS %s { kt: %d }" % (ctx.label, len(ctx.files.srcs)),
        input_manifests = input_manifests,
    )

    return [
        DefaultInfo(
            files = depset([ctx.outputs.js, ctx.outputs.js_map]),
        ),
        _KtJsInfo(
            js = ctx.outputs.js,
            js_map = ctx.outputs.js_map,
            jar = ctx.outputs.jar,
            srcjar = ctx.outputs.srcjar,
        ),
    ]

def _strip_version(jarfile):
    """strip version suffix if present
       e.g. kotlinx-html-js-0.6.12.jar ->  kotlinx-html-js.jar
    """
    if not jarfile.endswith(".jar"):
        fail("_strip_version expects paths ending with .jar")
    segments = jarfile[:-len(".jar")].split("-")

    # Remove the last segment if all digits separated by dot
    parts = segments[-1].split(".")
    if len([p for p in parts if not p.isdigit()]) == 0:
        segments = segments[0:-1]
    return "%s.jar" % "-".join(segments)

def kt_js_import_impl(ctx):
    if len(ctx.files.jars) != 1:
        fail("a single jar should be supplied, multiple jars not supported")
    jar_file = ctx.files.jars[0]

    srcjar = ctx.files.srcjar[0] if len(ctx.files.srcjar) == 1 else None

    args = ctx.actions.args()
    args.add("--jar", jar_file)
    args.add("--import_pattern", "^[^/.]+\\.js$")
    args.add("--import_out", ctx.outputs.js)
    args.add("--aux_pattern", "^[^/]+\\.js\\.map$")
    args.add("--aux_out", ctx.outputs.js_map)

    tools, _, input_manifest = ctx.resolve_command(tools = [ctx.attr._importer])
    ctx.actions.run(
        inputs = [jar_file],
        tools = tools,
        executable = ctx.executable._importer,
        outputs = [
            ctx.outputs.js,
            ctx.outputs.js_map,
        ],
        arguments = [args],
        input_manifests = input_manifest,
    )

    return [
        DefaultInfo(
            files = depset([ctx.outputs.js, ctx.outputs.js_map]),
        ),
        _KtJsInfo(
            js = ctx.outputs.js,
            js_map = ctx.outputs.js_map,
            jar = jar_file,
            srcjar = srcjar,
        ),
    ]
