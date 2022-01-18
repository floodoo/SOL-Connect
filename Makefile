ROOT := $(shell git rev-parse --show-toplevel)
FLUTTER := $(shell which flutter)
FLUTTER_BIN_DIR := $(shell dirname $(FLUTTER))
FLUTTER_DIR := $(FLUTTER_BIN_DIR:/bin=)
DART := $(FLUTTER_BIN_DIR)/cache/dart-sdk/bin/dart

format:
	@echo "╠ Format code..."
	$(FLUTTER) format . --line-length 120 --set-exit-if-changed

format-fix: 
	@echo "╠ Format code..."
	$(FLUTTER) format . --line-length 120

analyze:
	@echo "╠ Verifying code..."
	$(FLUTTER) analyze

tests:
	@echo "╠ Running tests..."
	$(FLUTTER) test

outdated:
	@echo "╠ Check outdated dependencies..."
	$(FLUTTER) pub outdated

upgrade-packages:
	@echo "╠ Upgrading dependencies..."
	$(FLUTTER) pub upgrade

clean:
	@echo "╠ Cleaning project..."
	$(FLUTTER) clean
	$(FLUTTER) pub get
	make format-fix

clean-hard:
	@echo "╠ Hard cleaning project..."
	rm pubspec.lock
	rm ios/Podfile.lock
	rm -rf ios/Pods
	rm -rf ios/Runner.xcworkspace
	cd ios && pod install --repo-update && cd ..
	# rm -rf ios/.symlinks
	# pod cache clean --all
	# rm -rf ios/Flutter/Flutter.framework
	# $(FLUTTER) pub cache repair
	make clean
	$(FLUTTER) pub upgrade

build-android-debug-apk:
	@echo "╠ Building android debug apk..."
	$(FLUTTER) packages get
	$(FLUTTER) clean
	$(FLUTTER) build apk --debug

build-android-release-apk:
	@echo "╠ Building android release apk..."
	$(FLUTTER) packages get
	$(FLUTTER) clean
	$(FLUTTER) build apk --release
	mkdir build-output
	cp build/app/outputs/flutter-apk/app-release.apk build-output/
	mv build-output/app-release.apk build-output/untis_phasierung_release.apk

build-android-release-aab:
	@echo "╠ Building android aab..."
	$(FLUTTER) packages get
	$(FLUTTER) clean
	$(FLUTTER) build appbundle --release
