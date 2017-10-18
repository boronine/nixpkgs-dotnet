# Nix sandbox for .NET Core CLR package

```bash
$ ./prep.sh
$ nix-shell
$ cd coreclr-2.0.0
$ patchShebangs .
$ ./build.sh x64 Release
```
