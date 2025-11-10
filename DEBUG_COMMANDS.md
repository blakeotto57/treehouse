# Flutter Chrome Debug Commands

## Basic Debug Command

```bash
flutter run -d chrome
```

This runs in **debug mode by default** (with hot reload, DevTools, etc.)

## With Custom Port

```bash
flutter run -d chrome --web-port=8080
```

## Debug Mode Options

### Standard Debug (Default):
```bash
flutter run -d chrome --debug
```

### Release Mode (No debugging):
```bash
flutter run -d chrome --release
```

### Profile Mode (Performance profiling):
```bash
flutter run -d chrome --profile
```

## Debug Features Available

When running in debug mode, you get:

1. **Hot Reload**: Press `r` in terminal
2. **Hot Restart**: Press `R` in terminal
3. **DevTools**: Open Flutter DevTools for debugging
4. **Debug Console**: See errors and logs in terminal
5. **Breakpoints**: Set breakpoints in your code
6. **Inspector**: Inspect widget tree

## Quick Launch

**Double-click:** `run_debug.bat` to start debug mode

## Useful Debug Commands While Running

- `r` - Hot reload (preserves state)
- `R` - Hot restart (resets state)
- `q` - Quit
- `h` - List all available commands
- `d` - Open DevTools

## Open DevTools Manually

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Then open: http://localhost:9100

## Debug with Verbose Output

```bash
flutter run -d chrome --verbose
```

## Common Debug Flags

```bash
# Enable web renderer (auto-detected, but you can specify)
flutter run -d chrome --web-renderer html
flutter run -d chrome --web-renderer canvaskit

# Disable caching
flutter run -d chrome --no-sound-null-safety

# Enable null safety
flutter run -d chrome --sound-null-safety
```

## Troubleshooting

### Clear build cache:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### See all available devices:
```bash
flutter devices
```

### Check for errors before running:
```bash
flutter analyze
```

