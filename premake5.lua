project "assimp"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "off"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

    -- Use CMake to configure and build Assimp
    prebuildcommands
    {
        -- Configure with CMake (only run once)
        "cd %{prj.location} && if not exist build mkdir build",
        "cd %{prj.location}/build && cmake .. -G \"Visual Studio 17 2022\" -A x64 -DASSIMP_BUILD_TESTS=OFF -DASSIMP_BUILD_ASSIMP_TOOLS=OFF -DASSIMP_BUILD_SAMPLES=OFF -DASSIMP_INSTALL=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_DEBUG_POSTFIX=d",
        -- Build the library
        "cd %{prj.location}/build && cmake --build . --config %{cfg.buildcfg} --target assimp",
        
        -- Create predictable library names (catch-all approach)
        "cd %{prj.location}/build && if exist lib\\%{cfg.buildcfg}\\*.lib (for /f \"delims=\" %%i in ('dir /b lib\\%{cfg.buildcfg}\\*.lib') do (if \"%{cfg.buildcfg}\"==\"Debug\" (copy \"lib\\%{cfg.buildcfg}\\%%i\" \"lib\\%{cfg.buildcfg}\\assimpd.lib\" >nul 2>&1) else (copy \"lib\\%{cfg.buildcfg}\\%%i\" \"lib\\%{cfg.buildcfg}\\assimp.lib\" >nul 2>&1)))",
        
        -- also check bin directory
        "cd %{prj.location}/build && if exist bin\\%{cfg.buildcfg}\\*.lib (for /f \"delims=\" %%i in ('dir /b bin\\%{cfg.buildcfg}\\*.lib') do (if \"%{cfg.buildcfg}\"==\"Debug\" (copy \"bin\\%{cfg.buildcfg}\\%%i\" \"bin\\%{cfg.buildcfg}\\assimpd.lib\" >nul 2>&1) else (copy \"bin\\%{cfg.buildcfg}\\%%i\" \"bin\\%{cfg.buildcfg}\\assimp.lib\" >nul 2>&1)))"
    }

    -- Link the built library (catch-all libdirs)
    libdirs
    {
        "%{prj.location}/build/lib/%{cfg.buildcfg}",
        "%{prj.location}/build/bin/%{cfg.buildcfg}",
        "%{prj.location}/build/lib",
        "%{prj.location}/build/bin",
        "%{prj.location}/lib/%{cfg.buildcfg}",
        "%{prj.location}/lib"
    }

    -- Catch-all library linking approach
    filter "system:windows"
        systemversion "latest"
        -- Try multiple possible library names - linker uses first found
        links { 
            "assimp",           -- Standard name we create
            "libassimp",        -- Alternative name
            "assimp-vc143-mt",  -- VS2022 specific
            "assimp-vc142-mt",  -- VS2019 specific  
            "assimp-vc141-mt"   -- VS2017 specific
        }

    filter "system:windows and configurations:Debug"
        links { 
            "assimpd",          -- Debug name we create
            "assimp_d",         -- Alternative debug name
            "assimp-vc143-mtd", -- VS2022 debug
            "assimp-vc142-mtd", -- VS2019 debug
            "assimp-vc141-mtd"  -- VS2017 debug
        }

    filter "system:linux"
        links { "assimp", "pthread", "dl", "z" }

    includedirs
    {
        "include",
        "build/include" -- CMake generates some headers here
    }

    filter "system:windows"
        systemversion "latest"

    filter "configurations:Debug"
        runtime "Debug"
        symbols "on"

    filter "configurations:Release"
        runtime "Release"
        optimize "on"

    filter "configurations:Dist"
        runtime "Release"
        optimize "on"
