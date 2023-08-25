# ScanSweep

A Mac App to find and delete unused image resources from your Xcode project.

It will scan current folder and all its subfolders to find unused images, then ask you whether you want to delete them.

## Usage

1. Click `Browse...` to select the project folder.
2. Filter scope search with `Exclude Paths`, `File Extensions`, and `Resources Extensions`.
3. Click "Search..." to start searching unused resources.
4. Wait a few seconds, the unused results will be shown in the table.
5. Select files to `Delete`, and `Delete All` to delete all usuned

**Note:** Please make sure you have a backup or a version control system before you deleting the images; it will be an un-restorable operation.



## Reliability

ScanSweep depends on using [FengNiao](https://github.com/onevcat/FengNiao) as a backend.

If you refer original and command-line tool. Please visit [FengNiao](https://github.com/onevcat/FengNiao).

## License

ScanSweep is licensed under MIT so that you can do whatever you want with this source code.

However, please do not ship this app under your own account.