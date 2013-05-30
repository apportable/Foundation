flags = [
    '-fdollars-in-identifiers',
    # They know what they are doing...
    '-Wno-deprecated-objc-isa-usage',
    '-Wno-cast-of-sel-type',
    '-Wno-deprecated-declarations',
    '-Wno-objc-root-class',
    '-Wno-format',
]

defines = {
    'BUILDING_OBJC_RUNTIME': 1,
    'NDEBUG' : 1,
}

header_paths = [
    "objc4-532.2",
    "objc4-532.2/runtime",
    "objc4-532.2/runtime/Accessors.subproj",
    "../dispatch/include",
    "libclosure-59"
]

deps = [
    'v',
    'cxx',
    'System',
]

sources = [
    'objc4-532.2/runtime/hashtable2.mm',
    'objc4-532.2/runtime/maptable.mm',
    'objc4-532.2/runtime/objc-auto.m',
    'objc4-532.2/runtime/objc-cache.mm',
    'objc4-532.2/runtime/objc-class-old.m',
    'objc4-532.2/runtime/objc-class.mm',
    'objc4-532.2/runtime/objc-errors.mm',
    'objc4-532.2/runtime/objc-exception.mm',
    'objc4-532.2/runtime/objc-file.mm',
    'objc4-532.2/runtime/objc-initialize.mm',
    'objc4-532.2/runtime/objc-layout.mm',
    'objc4-532.2/runtime/objc-load.mm',
    'objc4-532.2/runtime/objc-loadmethod.mm',
    'objc4-532.2/runtime/objc-lockdebug.mm',
    'objc4-532.2/runtime/objc-runtime-new.mm',
    'objc4-532.2/runtime/objc-runtime-old.m',
    'objc4-532.2/runtime/objc-runtime.mm',
    'objc4-532.2/runtime/objc-sel-set.mm',
    'objc4-532.2/runtime/objc-sel.mm',
    'objc4-532.2/runtime/objc-sync.mm',
    'objc4-532.2/runtime/objc-typeencoding.mm',
    # 'objc4-532.2/runtime/Object.m',
    'objc4-532.2/runtime/Protocol.mm',
    'objc4-532.2/runtime/OldClasses.subproj/List.m',
    'objc4-532.2/runtime/Messengers.subproj/objc-msg-arm.S',
    # 'objc4-532.2/runtime/Messengers.subproj/objc-msg-i386.s',
    # 'objc4-532.2/runtime/Messengers.subproj/objc-msg-x86_64.s',
    'objc4-532.2/runtime/Accessors.subproj/objc-accessors.mm',
    'objc4-532.2/runtime/objc-references.mm',
    'objc4-532.2/runtime/objc-os.mm',
    # 'objc4-532.2/runtime/objc-probes.d',
    'objc4-532.2/runtime/objc-auto-dump.m',
    'objc4-532.2/runtime/objc-file-old.m',
    # 'objc4-532.2/runtime/a1a2-blocktramps-i386.s',
    # 'objc4-532.2/runtime/a1a2-blocktramps-x86_64.s',
    # 'objc4-532.2/runtime/a2a3-blocktramps-i386.s',
    # 'objc4-532.2/runtime/a2a3-blocktramps-x86_64.s',
    # 'objc4-532.2/runtime/objc-block-trampolines.mm',
    # 'objc4-532.2/runtime/Messengers.subproj/objc-msg-simulator-i386.s',
    'objc4-532.2/runtime/objc-sel-table.S',
    # 'objc4-532.2/runtime/a1a2-blocktramps-arm.S',
    # 'objc4-532.2/runtime/a2a3-blocktramps-arm.S',
    'objc4-532.2/runtime/objc-externalref.mm',
    'objc4-532.2/runtime/objc-weak.mm',
    'objc4-532.2/runtime/NSObject.mm',
    'objc4-532.2/runtime/objc-opt.mm',
    'libclosure-59/runtime.c',
    'libclosure-59/data.c',
    'libclosure-59/NSBlock.mm',
    'objc/objc-block-trampolines.m',
    'objc/block_trampolines.S',
]

libs = [
    'v',
    'cxx',
    'System',
]

Import('env')
env.BuildLibrary(sources = sources, header_paths = header_paths, static=False, defines = defines, flags = flags, deps = deps, libs=libs)