#! /usr/bin/env python3

import json, subprocess, time, threading, re

def win_title_loop():
    global win_title

    while True:
        win_title = subprocess.check_output("swaymsg -t get_tree | jq -r '.. | select(.focused?) | .name'", shell=True).strip().decode("utf-8")
        win_title = (win_title[:100] + "...") if len(win_title) > 50 else win_title
        win_title = " {} ".format(win_title) if win_title else ""
        time.sleep(0.2)

def mem_loop():
    global ram_percent, swap_percent

    while True:
        meminfo = open("/proc/meminfo", "r").read()
        arcstats = open("/proc/spl/kstat/zfs/arcstats", "r").read()

        mem_total = int(re.search(r"^MemTotal: +([0-9]+) kB$", meminfo, re.MULTILINE).group(1)) * 1000
        mem_available = int(re.search(r"^MemAvailable: +([0-9]+) kB$", meminfo, re.MULTILINE).group(1)) * 1000
        arc_size = int(re.search(r"^size +4 +([0-9]+)$", arcstats, re.MULTILINE).group(1))
        swap_total = int(re.search(r"^SwapTotal: +([0-9]+) kB$", meminfo, re.MULTILINE).group(1)) * 1000
        swap_free = int(re.search(r"^SwapFree: +([0-9]+) kB$", meminfo, re.MULTILINE).group(1)) * 1000

        ram_percent = int((mem_total - mem_available - arc_size) / mem_total * 100)
        swap_percent = int((swap_total - swap_free) / swap_total * 100)
        time.sleep(1.0)

def cpu_loop():
    global cpu_percent, cpu_temp

    last_idle = 0
    last_total = 0

    while True:
        with open("/proc/stat", "r") as f:
            fields = [float(column) for column in f.readline().strip().split()[1:]]

        idle = fields[3]
        total = sum(fields)

        idle_delta = idle - last_idle
        total_delta = total - last_total

        last_idle = idle
        last_total = total

        cpu_percent = int(100.0 * (1.0 - idle_delta / total_delta))

        cpu_temp = int(int(open("/sys/class/hwmon/hwmon1/temp1_input", "r").readline().strip()) / 1000)
        time.sleep(1.0)

def gpu_loop():
    global gpu_temp

    while True:
        gpu_temp = int(int(open("/sys/class/hwmon/hwmon2/temp2_input", "r").readline().strip()) / 1000)
        time.sleep(1.0)

def date_loop():
    global date

    while True:
        date = time.strftime("%B %d, %G - %H:%M")
        time.sleep(1.0)

if __name__ == "__main__":
    win_title = ""
    ram_percent = 0
    swap_percent = 0
    cpu_percent = 0
    cpu_temp = 0
    gpu_temp = 0
    date = ""

    print("{\"version\":1}")
    print("[[],")

    threading.Thread(target=win_title_loop).start()
    threading.Thread(target=mem_loop).start()
    threading.Thread(target=cpu_loop).start()
    threading.Thread(target=gpu_loop).start()
    threading.Thread(target=date_loop).start()

    while True:
        output = [
            {
                "full_text": win_title,
                "color": "#ffffff",
                "background": "#d70a53",
            },
            {
                "full_text": "RAM: {}%".format(ram_percent),
                "color": "#ffffff",
                "background": "#222222",
                "urgent": ram_percent > 90,
            },
            {
                "full_text": "Swap: {}%".format(swap_percent),
                "color": "#ffffff",
                "background": "#222222",
                "urgent": swap_percent > 50,
            },
            {
                "full_text": "CPU: {}%".format(cpu_percent),
                "color": "#ffffff",
                "background": "#222222",
                "urgent": cpu_percent > 90,
            },
            {
                "full_text": "CPU Temp: {}°C".format(cpu_temp),
                "color": "#ffffff",
                "background": "#222222",
                "urgent": cpu_temp > 80,
            },
            {
                "full_text": "GPU Temp: {}°C".format(gpu_temp),
                "color": "#ffffff",
                "background": "#222222",
                "urgent": gpu_temp > 80,
            },
            {
                "full_text": date,
                "color": "#ffffff",
                "background": "#222222",
            },
        ]
        print(json.dumps(output, sort_keys=True, indent=2) + ",", flush=True)
        time.sleep(0.1)
