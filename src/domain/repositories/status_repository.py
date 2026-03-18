from abc import ABC, abstractmethod

from domain.models.device_status import DeviceStatus


class StatusRepository(ABC):
    @abstractmethod
    def save(self, status: DeviceStatus) -> None:
        ...
