from domain.repositories.device_repository import DeviceRepository
from domain.repositories.status_repository import StatusRepository


class CollectStatusUseCase:
    def __init__(
        self, device_repo: DeviceRepository, status_repo: StatusRepository
    ) -> None:
        self._device_repo = device_repo
        self._status_repo = status_repo

    def execute(self) -> None:
        statuses = self._device_repo.fetch_all_statuses()
        for status in statuses:
            self._status_repo.save(status)
