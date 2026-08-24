#!/usr/bin/env python3
"""Capture real App Store screenshots from the running app in the iOS Simulator.

Boots an iPhone 6.7" and a 12.9" iPad, installs the built .app, launches it with
-screenshot <n> to seed demo data / deep-link into the editor, and grabs the
actual on-device frame. Output is normalized to the exact resolution App Store
Connect expects for each display type.

Usage: capture_screenshots.py <path-to-LazyChart.app>
"""
import json, subprocess, sys, time, os
from PIL import Image

BUNDLE = "com.tokyonasu.LazyChart"
APP = sys.argv[1]

# Ordered preferences; first available match wins.
IPHONE_PREFS = ["iPhone 16 Pro Max", "iPhone 15 Pro Max", "Pro Max"]
IPAD_PREFS = ["iPad Pro (12.9-inch)", "iPad Pro 13-inch", "iPad Pro", "iPad Air 13-inch", "iPad Air", "iPad"]

# Target resolutions required by APP_IPHONE_67 and APP_IPAD_PRO_3GEN_129.
IPHONE_SIZE = (1290, 2796)
IPAD_SIZE = (2048, 2732)

SCREENS = ["1", "2", "3"]  # 1=list, 2=bar editor, 3=pie editor


def sh(*a):
    return subprocess.run(a, check=True, capture_output=True, text=True)


def list_devices():
    data = json.loads(sh("xcrun", "simctl", "list", "devices", "available", "--json").stdout)["devices"]
    devs = []
    for runtime, lst in data.items():
        if "iOS" not in runtime:
            continue
        for d in lst:
            if d.get("isAvailable"):
                devs.append(d)
    return devs


def pick(devs, prefs):
    for p in prefs:
        for d in devs:
            if p in d["name"]:
                return d
    return None


def ensure_booted(udid):
    subprocess.run(["xcrun", "simctl", "boot", udid], capture_output=True)
    sh("xcrun", "simctl", "bootstatus", udid, "-b")


def capture(udid, screen, out):
    subprocess.run(["xcrun", "simctl", "terminate", udid, BUNDLE], capture_output=True)
    sh("xcrun", "simctl", "launch", udid, BUNDLE,
       "-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP", "-screenshot", screen)
    time.sleep(8)
    sh("xcrun", "simctl", "io", udid, "screenshot", out)


def normalize(path, size):
    im = Image.open(path).convert("RGB")
    if im.size != size:
        im = im.resize(size, Image.LANCZOS)
        im.save(path)


def run_device(dev, folder, size):
    udid = dev["udid"]
    print("Using", dev["name"], udid)
    ensure_booted(udid)
    sh("xcrun", "simctl", "install", udid, APP)
    os.makedirs(folder, exist_ok=True)
    for i, screen in enumerate(SCREENS, 1):
        out = os.path.join(folder, f"{i}.png")
        capture(udid, screen, out)
        normalize(out, size)
        print("saved", out)


def main():
    devs = list_devices()
    iphone = pick(devs, IPHONE_PREFS)
    ipad = pick(devs, IPAD_PREFS)
    if not iphone or not ipad:
        print("available devices:", [d["name"] for d in devs])
        raise SystemExit("Required simulators not found")
    run_device(iphone, "shots/iphone", IPHONE_SIZE)
    run_device(ipad, "shots/ipad", IPAD_SIZE)
    print("Screenshots captured")


if __name__ == "__main__":
    main()
