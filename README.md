# Running Coach App

A Flutter application that provides voice coaching for running pace goals. The app tracks your location, calculates your current pace, and provides voice feedback to help you maintain your target pace.

## Features

- **Pace Selection**: Set your target pace using an intuitive slider (3:00 to 8:00 min/km)
- **Real-time Tracking**: GPS-based location tracking with high accuracy
- **Voice Feedback**: Automatic voice prompts to speed up or slow down based on your current pace
- **Live Metrics**: Real-time display of elapsed time, distance, and current pace
- **Modern UI**: Clean, intuitive interface with Material Design 3

## How It Works

1. **Set Your Target Pace**: Use the slider to select your desired pace (e.g., 5:00 min/km)
2. **Start Running**: Press the "Start Running" button to begin tracking
3. **Voice Coaching**: The app will provide voice feedback:
   - "Speed up" when you're running slower than your target pace
   - "Slow down" when you're running faster than your target pace
4. **Monitor Progress**: View real-time metrics including time, distance, and current pace
5. **Stop Session**: Press "Stop Running" to end the session

## Technical Details

- **Location Tracking**: Uses high-accuracy GPS with 10-meter distance filter
- **Pace Calculation**: Real-time pace calculation based on distance and elapsed time
- **Voice Feedback**: Text-to-speech with 12-second tolerance for pace adjustments
- **State Management**: Provider pattern for reactive UI updates

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android device or emulator / iOS device or simulator

### Installation

1. **Clone or download the project**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Permissions

The app requires the following permissions:

- **Location Access**: For GPS tracking and pace calculation
- **Text-to-Speech**: For voice feedback

The app will request these permissions when you first start a running session.

## Dependencies

- `geolocator`: GPS location tracking
- `flutter_tts`: Text-to-speech functionality
- `permission_handler`: Permission management
- `provider`: State management

## Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+

## Usage Tips

1. **Ensure GPS Signal**: Make sure you have a good GPS signal before starting
2. **Allow Permissions**: Grant location permissions when prompted
3. **Start Outdoors**: Begin your run outdoors for better GPS accuracy
4. **Listen for Feedback**: The voice feedback will help you maintain your target pace
5. **Monitor Metrics**: Keep an eye on the real-time metrics to track your progress

## Troubleshooting

### Common Issues

1. **No GPS Signal**: 
   - Ensure you're outdoors
   - Check that location services are enabled
   - Wait a few moments for GPS to acquire signal

2. **Voice Not Working**:
   - Check device volume
   - Ensure text-to-speech is enabled on your device
   - Grant necessary permissions

3. **Inaccurate Pace**:
   - Wait for the app to gather more GPS points (100m minimum)
   - Ensure you're moving at a consistent pace
   - Check GPS accuracy in your device settings

### Performance Tips

- Keep the app in the foreground for best GPS accuracy
- Use headphones for clearer voice feedback
- Start your run after the app has acquired a GPS signal

## Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers/
│   └── running_provider.dart # State management
├── screens/
│   └── home_screen.dart      # Main UI screen
└── widgets/
    ├── pace_selector.dart    # Pace selection UI
    ├── running_metrics.dart  # Metrics display
    └── control_buttons.dart  # Start/stop controls
```

### Key Components

- **RunningProvider**: Manages running state, GPS tracking, and voice feedback
- **HomeScreen**: Main UI that orchestrates all components
- **PaceSelector**: Interactive pace selection with slider
- **RunningMetrics**: Real-time display of running data
- **ControlButtons**: Start/stop functionality

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the [MIT License](LICENSE). 