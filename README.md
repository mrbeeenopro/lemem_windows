# Windows 11 VM Egg for Pterodactyl

![Preview]([https://cdn.bosd.io.vn/windows11.png](https://pub-cc2caec4959546c9b98850c80420b764.r2.dev/panel.png)

Introduces a Windows 11 virtualization Egg designed for use on the Pterodactyl panel. It allows you to run a lightweight Windows 11 virtual machine inside a container using QEMU/KVM. The Egg supports user‑configured RAM through the `VM_MEMORY` variable.

---

## 🖥️ Overview

This Egg provides a fully automated setup for launching a Windows 11 environment inside Pterodactyl. It is optimized for:

![Preview](https://cdn.bosd.io.vn/windows11.png)

* Virtualized desktop usage
* Background Windows tasks
* Automation or tooling that requires Windows compatibility
* Labs, demos, or testing
* ✅ support kvm
* ✅ live web vnc srceen
* ✅ multi core support
* ⚠️ support rdp(with rustdesk or tunnel app)
* ❌ shared folder with host
The Egg uses QEMU/KVM to emulate hardware and boots from a Windows 11 disk image supplied by the user.

---

## ⚙️ Environment Variable: `VM_MEMORY`

`VM_MEMORY` defines the amount of RAM (in MB) allocated to the virtual machine.

Example:

```
VM_MEMORY=4096
```

This allocates 4 GB of RAM to the Windows 11 VM.

> ⚠️ Note: The host system will always consume additional RAM above what is assigned to the VM. See table below.

---

## 📊 QEMU RAM Overhead Reference Table

Use this table to estimate how much RAM your host machine will consume based on the VM configuration.

| VM Cores | VM RAM | Average Overhead | Overhead % | Total Host Usage |
| -------- | ------ | ---------------- | ---------- | ---------------- |
| 1 core   | 1 GB   | ~350 MB          | 35%        | ~1.35 GB         |
| 1 core   | 2 GB   | ~700 MB          | 35%        | ~2.7 GB          |
| 2 core   | 2 GB   | ~850 MB          | 42%        | ~2.85 GB         |
| 2 core   | 4 GB   | ~1.4 GB          | 35%        | ~5.4 GB          |
| 4 core   | 4 GB   | ~1.7 GB          | 42%        | ~5.7 GB          |
| 4 core   | 8 GB   | ~2.6 GB          | 32%        | ~10.6 GB         |
| 8 core   | 8 GB   | ~3.4 GB          | 42%        | ~11.4 GB         |
| 8 core   | 16 GB  | ~4.8 GB          | 30%        | ~20.8 GB         |

---

## 🧩 Why Overhead Happens

**1. More CPU cores → higher overhead**
QEMU must handle more CPU threads, synchronization, and virtualization layers.

**2. More RAM → increased cache and memory management**
Features like page cache, huge pages, and disk I/O buffers scale with memory size.

**3. Typical overhead ranges**

* Light VMs (1–2 GB RAM): **35–45%**
* Medium VMs (4–8 GB RAM): **30–40%**
* Large VMs (16+ GB): **25–32%**

---

## 📞 Support

If you need assistance, feel free to ask for troubleshooting, contact via [discord](https://discord.gg/AqrUvWkxU8).

---

Enjoy using Windows 11 on your Pterodactyl panel!
