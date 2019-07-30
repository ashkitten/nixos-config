use libc::c_ulong;
use nix::{convert_ioctl_res, ioctl_write_int_bad};
use std::os::unix::io::AsRawFd;
use std::{fs, thread, time};

const KIOCSOUND: c_ulong = 0x00004B2F;
ioctl_write_int_bad!(kiocsound, KIOCSOUND);

const CLOCK_TICK_RATE: i32 = 1193180;

const TONES: [(i32, u64); 23] = [
    (659, 460),
    (784, 340),
    (659, 230),
    (659, 110),
    (880, 230),
    (659, 230),
    (587, 230),
    (659, 460),
    (988, 340),
    (659, 230),
    (659, 110),
    (1047, 230),
    (988, 230),
    (784, 230),
    (659, 230),
    (988, 230),
    (1318, 230),
    (659, 110),
    (587, 230),
    (587, 110),
    (494, 230),
    (740, 230),
    (659, 460),
];

fn main() {
    let tty = fs::File::open("/dev/tty0").unwrap();

    for (frequency, duration) in &TONES {
        unsafe {
            kiocsound(tty.as_raw_fd(), CLOCK_TICK_RATE / *frequency).unwrap();
            thread::sleep(time::Duration::from_millis(*duration));
            kiocsound(tty.as_raw_fd(), 0).unwrap();
        }
    }
}
