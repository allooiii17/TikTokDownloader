TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TikTokDownloadButton
TikTokDownloadButton_FILES = Tweak.x
TikTokDownloadButton_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

