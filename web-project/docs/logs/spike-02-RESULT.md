spike 02 fail: ofelia updateOF forced -std=c++14; OF nightly needs std::filesystem (c++17+)
/home/name/Desktop/filter2309/web-project/vendor/emsdk/upstream/emscripten/cache/sysroot/include/c++/v1/__config:425:84: note: expanded from macro '_LIBCPP_BEGIN_NAMESPACE_FILESYSTEM'
  425 | #  define _LIBCPP_BEGIN_NAMESPACE_FILESYSTEM _LIBCPP_BEGIN_NAMESPACE_STD namespace filesystem {
      |                                                                                    ^
In file included from ../../../libs/openFrameworks/app/ofAppNoWindow.cpp:3:
In file included from ../../../libs/openFrameworks/graphics/ofPath.h:3:
In file included from ../../../libs/openFrameworks/graphics/ofPolyline.h:573:
In file included from ../../../libs/openFrameworks/graphics/ofPolyline.inl:8:
In file included from ../../../libs/openFrameworks/utils/ofLog.h:4:
../../../libs/openFrameworks/utils/ofFileUtils.h:339:63: error: no type named 'path' in namespace 'std::filesystem'
  339 |         static std::string getPathForDirectory(const of::filesystem::path & path);
      |                                                          ~~~~~~~~~~~~^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
2 errors generated.
make[2]: *** [makefileCommon/compile.core.mk:259: ../../../libs/openFrameworksCompiled/lib/emscripten/obj/Release/libs/openFrameworks/app/ofMainLoop.o] Error 1
make[2]: *** Waiting for unfinished jobs....
20 errors generated.
make[2]: *** [makefileCommon/compile.core.mk:259: ../../../libs/openFrameworksCompiled/lib/emscripten/obj/Release/libs/openFrameworks/app/ofAppNoWindow.o] Error 1
make[1]: *** [makefileCommon/compile.core.mk:225: Release] Error 2
make[1]: Leaving directory '/home/name/Desktop/filter2309/web-project/vendor/openFrameworks/libs/openFrameworksCompiled/project'
make: *** [/home/name/Desktop/filter2309/web-project/vendor/openFrameworks/libs/openFrameworksCompiled/project/makefileCommon/compile.project.mk:127: Release] Error 2
