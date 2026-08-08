APP     = LoremSlider
BUNDLE  = $(APP).app
EXEC    = $(BUNDLE)/Contents/MacOS/$(APP)
SOURCES = $(wildcard Sources/*.swift)

.PHONY: all clean run

all: $(BUNDLE)

$(BUNDLE): $(SOURCES) Resources/Info.plist Resources/AppIcon.icns Resources/en.lproj/Localizable.strings Resources/es.lproj/Localizable.strings
	@mkdir -p $(BUNDLE)/Contents/MacOS
	@mkdir -p $(BUNDLE)/Contents/Resources
	swiftc $(SOURCES) \
		-framework Cocoa \
		-o $(EXEC)
	@cp Resources/Info.plist $(BUNDLE)/Contents/Info.plist
	@cp Resources/AppIcon.icns $(BUNDLE)/Contents/Resources/AppIcon.icns
	@cp -R Resources/en.lproj $(BUNDLE)/Contents/Resources/en.lproj
	@cp -R Resources/es.lproj $(BUNDLE)/Contents/Resources/es.lproj
	@echo "✓ Built $(BUNDLE)"

run: all
	open $(BUNDLE)

clean:
	rm -rf $(BUNDLE)
