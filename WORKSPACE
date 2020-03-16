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
workspace(name = "io_bazel_rules_kotlin")

local_repository(
    name = "node_example",
    path = "examples/node",
)

load("//kotlin/internal/repositories:repositories.bzl", "github_archive")

github_archive(
    name = "com_google_protobuf",
    commit = "09745575a923640154bcf307fba8aedff47f240a",  # v3.8.0, as of 2019-05-28
    repo = "google/protobuf",
    sha256 = "76ee4ba47dec6146872b6cd051ae5bd12897ef0b1523d5aeb56d81a5a4ca885a",
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_jar")

http_archive(
    name = "bazel_skylib",
    urls = ["https://github.com/bazelbuild/bazel-skylib/archive/0.8.0.tar.gz"],
    strip_prefix = "bazel-skylib-0.8.0",
    sha256 = "2ea8a5ed2b448baf4a6855d3ce049c4c452a6470b1efd1504fdb7c1c134d220a",
)

http_jar(
    name = "bazel_deps",
    sha256 = "05498224710808be9687f5b9a906d11dd29ad592020246d4cd1a26eeaed0735e",
    url = "https://github.com/hsyed/bazel-deps/releases/download/v0.1.0/parseproject_deploy.jar",
)

http_archive(
    name = "bazel_toolchains",
    sha256 = "5962fe677a43226c409316fcb321d668fc4b7fa97cb1f9ef45e7dc2676097b26",
    strip_prefix = "bazel-toolchains-be10bee3010494721f08a0fccd7f57411a1e773e",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/be10bee3010494721f08a0fccd7f57411a1e773e.tar.gz",
        "https://github.com/bazelbuild/bazel-toolchains/archive/be10bee3010494721f08a0fccd7f57411a1e773e.tar.gz",
    ],
)

load("@bazel_toolchains//rules:rbe_repo.bzl", "rbe_autoconfig")

# Creates toolchain configuration for remote execution with BuildKite CI
# for rbe_ubuntu1604
rbe_autoconfig(
    name = "buildkite_config",
)

load("//kotlin:kotlin.bzl", "kotlin_repositories", "kt_register_toolchains")

kotlin_repositories()

kt_register_toolchains()

# The following are to support building and running nodejs examples from src/test

http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "3356c6b767403392bab018ce91625f6d15ff8f11c6d772dc84bc9cada01c669a",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/0.36.1/rules_nodejs-0.36.1.tar.gz"],
)

load("@build_bazel_rules_nodejs//:defs.bzl", "yarn_install")

yarn_install(
    name = "node_ws",
    package_json = "@node_example//:package.json",
    yarn_lock = "@node_example//:yarn.lock",
)

RULES_JVM_EXTERNAL_TAG = "2.7"

RULES_JVM_EXTERNAL_SHA = "f04b1466a00a2845106801e0c5cec96841f49ea4e7d1df88dc8e4bf31523df74"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "org.jetbrains.kotlinx:atomicfu-js:0.13.1",
        "org.jetbrains.kotlinx:kotlinx-coroutines-core-js:1.3.2",
    ],
    repositories = [
        "https://maven-central.storage.googleapis.com/repos/central/data/",
        "https://repo1.maven.org/maven2",
    ],
)

