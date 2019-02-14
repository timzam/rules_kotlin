/*
 * Copyright 2018 The Bazel Authors. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.bazel.kotlin.builder.utils


import io.bazel.kotlin.model.JvmCompilationTask
import java.io.ByteArrayOutputStream
import java.io.ObjectOutputStream
import java.util.*

// TODO(hs) move the kapt specific stuff to the JVM package.
class KotlinCompilerPluginArgsEncoder(
    private val jarPath: String,
    private val pluginId: String
) {
    companion object {
        private fun encodeMap(options: Map<String, String>): String {
            val os = ByteArrayOutputStream()
            val oos = ObjectOutputStream(os)

            oos.writeInt(options.size)
            for ((key, value) in options.entries) {
                oos.writeUTF(key)
                oos.writeUTF(value)
            }

            oos.flush()
            return Base64.getEncoder().encodeToString(os.toByteArray())
        }
    }

    fun encode(context: CompilationTaskContext, task: JvmCompilationTask): List<String> {
        val javacArgs = mutableMapOf<String, String>(
            "-target" to task.info.toolchainInfo.jvm.jvmTarget
        )
        val d = task.directories
        if (task.inputs.processorsList.isNotEmpty()) {
            val args = mutableListOf("-Xplugin=$jarPath")
            args.addAll("-P", "plugin:$pluginId:sources=${d.generatedSources}")
            args.addAll("-P", "plugin:$pluginId:classes=${d.generatedClasses}")
            args.addAll("-P", "plugin:$pluginId:stubs=${d.temp}")
            args.addAll("-P", "plugin:$pluginId:incrementalData=${d.temp}")
            args.addAll("-P", "plugin:$pluginId:javacArguments=${javacArgs.let(Companion::encodeMap)}")
            args.addAll("-P", "plugin:$pluginId:aptMode=stubsAndApt")
            args.addAll("-P", "plugin:$pluginId:correctErrorTypes=true")
            context.whenTracing {
                args.addAll("-P", "plugin:$pluginId:verbose=true")
            }
            val processors = task.inputs.processorsList.joinToString(",")
            args.addAll("-P", "plugin:$pluginId:processors=$processors")
            task.inputs.processorpathsList.forEach {
                args.addAll("-P", "plugin:$pluginId:apclasspath=$it")
            }
            System.err.println(args)
            return args
        } else {
            return emptyList()
        }
    }
}