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
package(default_visibility = ["//visibility:public"])

load("//kotlin:kotlin.bzl", "kt_jvm_import")

java_binary(
    name = "bazel_deps",
    main_class = "com.github.johnynek.bazel_deps.ParseProject",
    runtime_deps = ["@bazel_deps//jar"],
)

kt_jvm_import(
    name = "kotlinx_coroutines",
    jars = [
        "@io_bazel_rules_kotlin_org_jetbrains_kotlinx_kotlinx_coroutines_core//jar",
    ],
)

java_plugin(
    name = "autovalue_plugin",
    generates_api = 1,
    processor_class = "com.google.auto.value.processor.AutoValueProcessor",
    visibility = ["//visibility:private"],
    deps = ["//third_party/jvm/com/google/auto/value:auto_value"],
)

java_library(
    name = "autovalue",
    exported_plugins = [":autovalue_plugin"],
    neverlink = 1,
    exports = ["//third_party/jvm/com/google/auto/value:auto_value_annotations"],
)

java_plugin(
    name = "dagger_component_plugin",
    generates_api = 1,
    processor_class = "dagger.internal.codegen.ComponentProcessor",
    visibility = ["//visibility:private"],
    deps = [
        "//third_party/jvm/com/google/dagger:dagger_compiler",
    ],
)

java_library(
    name = "dagger",
    exported_plugins = [":dagger_component_plugin"],
    exports = [
        "//third_party/jvm/com/google/dagger",
        "//third_party/jvm/javax/inject:javax_inject",
    ],
)

java_binary(
    name = "jarjar_runner",
    main_class = "org.pantsbuild.jarjar.Main",
    visibility = ["//visibility:public"],
    runtime_deps = ["//third_party/jvm/org/pantsbuild:jarjar"],
)
