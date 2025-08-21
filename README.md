## How to use

### Download tools
```
git clone --single-branch --depth=1 https://github.com/Tarnished70/BuildOS-T.git -b sgsi SGSITool
cd SGSITool
```

### For setting up requirements
```
sudo apt install unace unrar zip unzip p7zip-full p7zip-rar sharutils rar uudeview mpack arj cabextract rename liblzma-dev python3-pip brotli lz4 protobuf-compiler git gawk aria2 apktool default-jre
pip3 install backports.lzma protobuf twrpdtgen extract-dtb pycryptodome
```

### Generating GSI from stock firmware URL
Example: for making PixelOS of Pixel 7a firmware, you can use this command
```
sudo bash LinkToGSI.sh https://dl.google.com/dl/android/aosp/lynx-bp1a.250505.005.b1-factory-45a1393f.zip Pixel
```
