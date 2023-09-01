# ResourcePurgeX

A Mac App to find and delete unused image resources from your Xcode project.

It will scan the current folder and all its subfolders to find unused images, then ask whether you want to delete them.

## Installation

Download the `ResourcePurgeX.zip` file from [Releases](https://github.com/ldakhoa/ResourcePurgeX/releases).

ResourcePurgeX release version is always notarized by Apple before publishing to GitHub, so you can use it with peace of mind.

Or build and run the project directly by
```bash
git clone https://github.com/ldakhoa/ResourcePurgeX.git
cd ResourcePurgeX
xed . # Open ResourcePurgeX.xcodeproj
```

And waiting for dependencies to install, then press the run button or `cmd + r`

## Usage

1. Click `Browse...` to select the project folder.
2. Filter scope search with `Exclude Paths`, `File Extensions`, and `Resources Extensions`.
3. Click "Search..." to start searching for unused resources.
4. Wait a few seconds; the unused results will be shown in the table.
5. Select files to `Delete`, and `Delete All` to delete all unused resources

**Note:** Please ensure you have a backup or version control system before deleting the images; it will be unrestorable.

![Example](./example.gif)

## Reliability

It is recommended to review your assets before deleting them. An example of a common situation is when assets are marked as unused even though they are actually utilized. This can occur when you create a reference to a resource depending on specific conditions.

ResourcePurgeX depends on [FengNiao](https://github.com/onevcat/FengNiao) as a backend, with [fork version](https://github.com/ldakhoa/FengNiao) to modify some pieces of code to support SwiftUI and app feature.

If you refer original and the command-line tool. Please visit [FengNiao](https://github.com/onevcat/FengNiao).

## License

ResourcePurgeX is licensed under MIT so that you can do whatever you want with this source code.

However, please do not ship this app under your own account.
