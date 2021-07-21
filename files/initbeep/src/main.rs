use libc::c_ulong;
use nix::{convert_ioctl_res, ioctl_write_int_bad};
use std::os::unix::io::AsRawFd;
use std::{fs, thread, time};

const KIOCSOUND: c_ulong = 0x00004B2F;
ioctl_write_int_bad!(kiocsound, KIOCSOUND);

const CLOCK_TICK_RATE: i32 = 1193180;

const TONES: [(i32, u64); 236] = [
    (698, 170),
    (659, 170),
    (698, 170),
    (783, 170),
    (880, 513),
    (698, 170),
    (783, 170),
    (880, 342),
    (698, 170),
    (783, 170),
    (880, 342),
    (1046, 342),
    (783, 342),
    (783, 684),
    (659, 170),
    (698, 170),
    (783, 342),
    (523, 170),
    (783, 170),
    (698, 170),
    (659, 170),
    (698, 342),
    (587, 170),
    (698, 170),
    (783, 170),
    (880, 513),
    (698, 170),
    (783, 170),
    (880, 342),
    (698, 170),
    (783, 170),
    (880, 342),
    (1046, 342),
    (783, 342),
    (783, 1027),
    (739, 170),
    (783, 170),
    (880, 1370),
    (698, 84),
    (830, 84),
    (932, 1198),
    (830, 856),
    (1244, 684),
    (1108, 684),
    (698, 513),
    (739, 1198),
    (622, 84),
    (698, 84),
    (739, 84),
    (830, 84),
    (932, 1198),
    (830, 856),
    (1244, 684),
    (1108, 1370),
    (830, 170),
    (622, 170),
    (466, 170),
    (830, 170),
    (739, 684),
    (0, 343),
    (783, 342),
    (523, 170),
    (587, 342),
    (622, 513),
    (587, 170),
    (622, 342),
    (698, 342),
    (587, 513),
    (622, 342),
    (587, 170),
    (523, 342),
    (466, 170),
    (466, 856),
    (466, 342),
    (523, 170),
    (587, 342),
    (466, 342),
    (466, 170),
    (587, 342),
    (830, 342),
    (783, 170),
    (783, 170),
    (698, 342),
    (587, 342),
    (698, 170),
    (622, 684),
    (698, 684),
    (622, 684),
    (587, 684),
    (0, 343),
    (783, 342),
    (523, 170),
    (587, 342),
    (622, 513),
    (587, 170),
    (622, 342),
    (698, 342),
    (587, 513),
    (622, 342),
    (587, 170),
    (523, 342),
    (466, 1027),
    (932, 342),
    (783, 170),
    (698, 342),
    (622, 342),
    (698, 170),
    (622, 342),
    (698, 342),
    (622, 170),
    (622, 170),
    (698, 170),
    (466, 342),
    (932, 342),
    (783, 513),
    (698, 513),
    (622, 1370),
    (622, 170),
    (698, 170),
    (783, 1027),
    (698, 170),
    (622, 856),
    (622, 342),
    (698, 342),
    (523, 513),
    (783, 513),
    (783, 1370),
    (783, 170),
    (830, 170),
    (932, 513),
    (830, 513),
    (783, 513),
    (698, 513),
    (622, 342),
    (698, 170),
    (466, 1198),
    (466, 170),
    (466, 1198),
    (622, 170),
    (698, 170),
    (783, 1027),
    (698, 170),
    (622, 856),
    (622, 342),
    (698, 342),
    (932, 513),
    (932, 513),
    (587, 170),
    (622, 856),
    (523, 342),
    (622, 342),
    (698, 342),
    (622, 170),
    (698, 342),
    (622, 342),
    (698, 513),
    (622, 170),
    (698, 342),
    (783, 342),
    (830, 1541),
    (783, 684),
    (783, 170),
    (698, 170),
    (783, 170),
    (830, 170),
    (932, 513),
    (739, 170),
    (830, 170),
    (932, 342),
    (739, 170),
    (830, 170),
    (932, 342),
    (1108, 342),
    (830, 342),
    (830, 684),
    (698, 170),
    (739, 170),
    (830, 342),
    (554, 170),
    (830, 170),
    (739, 170),
    (698, 170),
    (739, 342),
    (622, 170),
    (739, 170),
    (830, 170),
    (932, 513),
    (739, 170),
    (830, 170),
    (932, 342),
    (739, 170),
    (830, 170),
    (932, 342),
    (1108, 342),
    (830, 342),
    (830, 1027),
    (783, 170),
    (830, 170),
    (932, 856),
    (739, 170),
    (698, 170),
    (739, 170),
    (830, 170),
    (932, 513),
    (739, 170),
    (830, 170),
    (932, 342),
    (739, 170),
    (830, 170),
    (932, 342),
    (1108, 170),
    (0, 172),
    (830, 170),
    (0, 172),
    (830, 684),
    (698, 170),
    (739, 170),
    (830, 342),
    (554, 170),
    (1108, 170),
    (987, 170),
    (932, 170),
    (739, 342),
    (698, 342),
    (698, 856),
    (932, 342),
    (932, 342),
    (987, 342),
    (932, 170),
    (830, 342),
    (987, 342),
    (932, 1198),
    (932, 342),
    (830, 684),
    (1108, 513),
    (932, 1541),
];

fn main() {
    let tty = fs::File::open("/dev/tty0").unwrap();

    for (frequency, duration) in &TONES {
        unsafe {
            kiocsound(tty.as_raw_fd(), CLOCK_TICK_RATE.checked_div(*frequency).or(Some(0)).unwrap()).unwrap();
            thread::sleep(time::Duration::from_millis(*duration));
            kiocsound(tty.as_raw_fd(), 0).unwrap();
        }
    }
}
