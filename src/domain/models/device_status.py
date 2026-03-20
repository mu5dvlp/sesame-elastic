from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class DeviceStatus:
    device_uuid: str
    nickname: str
    locked: bool
    battery: int
    timestamp: datetime
