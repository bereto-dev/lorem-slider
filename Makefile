APP     = LoremSlider
BUNDLE  = $(APP).app
EXEC    = $(BUNDLE)/Contents/MacOS/$(APP)
SOURCES = $(wildcard Sources/*.swift)
MIN_OS  = 11.0

.PHONY: all clean run

all: $(BUNDLE)

$(BUNDLE): $(SOURCES) Resources/Info.plist Resources/AppIcon.icns Resources/en.lproj/Localizable.strings Resources/es.lproj/Localizable.strings
	@mkdir -p $(BUNDLE)/Contents/MacOS
	@mkdir -p $(BUNDLE)/Contents/Resources
	swiftc $(SOURCES) \
		-framework Cocoa \
		-target x86_64-apple-macosx$(MIN_OS) \
		-o $(EXEC)-x86_64
	swiftc $(SOURCES) \
		-framework Cocoa \
		-target arm64-apple-macosx$(MIN_OS) \
		-o $(EXEC)-arm64
	lipo -create -output $(EXEC) $(EXEC)-x86_64 $(EXEC)-arm64
	@rm -f $(EXEC)-x86_64 $(EXEC)-arm64
	@cp Resources/Info.plist $(BUNDLE)/Contents/Info.plist
	@cp Resources/AppIcon.icns $(BUNDLE)/Contents/Resources/AppIcon.icns
	@rm -rf $(BUNDLE)/Contents/Resources/en.lproj $(BUNDLE)/Contents/Resources/es.lproj
	@cp -R Resources/en.lproj $(BUNDLE)/Contents/Resources/en.lproj
	@cp -R Resources/es.lproj $(BUNDLE)/Contents/Resources/es.lproj
	@echo "✓ Built universal $(BUNDLE) (x86_64 + arm64)"

run: all
	open $(BUNDLE)

clean:
	rm -rf $(BUNDLE)
