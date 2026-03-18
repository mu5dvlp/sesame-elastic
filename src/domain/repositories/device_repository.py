from abc import ABC, abstractmethod

from domain.models.device_status import DeviceStatus


class DeviceRepository(ABC):
    @abstractmethod
    def fetch_all_statuses(self) -> list[DeviceStatus]:
        ...
