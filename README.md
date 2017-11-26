# Merge-ZippedMix
Merges zipped mp3 files comprising a mix/album without re-encoding (using [mp3cat](https://github.com/dmulholland/mp3cat)).

## Details
This PowerShell script expects a zip file containing multiple mp3 files to be merged into a single mp3 file. It will do so without re-encoding, preserving the original audio quality. Specifically, the script will do the following:

1. Extract the mixed zip file into the `%TEMP%` folder.
1. Recursively look for an `mp3` file in that folder.
1. Run [mp3cat](https://github.com/dmulholland/mp3cat) on the folder where the first `mp3` file was found.
1. All mp3 files in the folder will be merged into `C:\foo\bar.mp3`, where `C:\foo\bar.zip` is the input zipped mix file.

## Prerequisites 
Make sure that [mp3cat](https://github.com/dmulholland/mp3cat) is either in your `PATH` or in the script's working folder.

## Usage
```posh
Merge-ZippedMix.ps1 mix.zip
```
- Both CBR and VBR mp3s are supported (by virtue of mp3cat).
 - The ID3 tag of the first mp3 file will be used for the merged file (using `mp3cat --tag`).

## Mass execution
 If you have multiple mix zip files in some folder and you'd like to merge all of them, try:
```posh
$mixes = Get-ChildItem "C:\MixFolder" -Filter *.zip
$mixes | foreach { .\Merge-ZippedMix.ps1 $_.FullName }
```
