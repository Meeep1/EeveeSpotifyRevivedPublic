TWEAK_NAME = EeveeSpotify
EeveeSpotify_FILES = Sources/EeveeSpotify/Tweak.x.swift \
                    Sources/EeveeSpotify/DataLoaderServiceHooks.x.swift \
                    Sources/EeveeSpotify/DarkPopUps.x.swift \
                    Sources/EeveeSpotify/SearchAdsHooks.x.swift \
                    Sources/EeveeSpotify/SessionProtection.x.swift \
                    Sources/EeveeSpotify/OpenSpotify.x.swift \
                    $(shell find Sources/EeveeSpotify/Premium -name "*.swift") \
                    $(shell find Sources/EeveeSpotify/Lyrics -name "*.swift") \
                    $(shell find Sources/EeveeSpotify/Settings -name "*.swift") \
                    $(shell find Sources/EeveeSpotify/Shared -name "*.swift") \
                    $(shell find Sources/EeveeSpotify/Experiments -name "*.swift") \
                    $(shell find Sources/EeveeSpotify/Dependencies -name "*.swift")

EeveeSpotify_SWIFTFLAGS = -ISources/EeveeSpotifyC/include
EeveeSpotify_FRAMEWORKS = UIKit Foundation SwiftUI

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
