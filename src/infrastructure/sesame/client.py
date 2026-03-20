import json
import urllib.request
from datetime import datetime, timezone

from domain.models.device_status import DeviceStatus
from domain.repositories.device_repository import DeviceRepository

_BASE_URL = "https://app.candyhouse.co/api"


class SesameApiClient(DeviceRepository):
    def __init__(self, api_key: str, device_uuids: list[str]) -> None:
        self._api_key = api_key
        self._device_uuids = device_uuids

    def _get(self, path: str) -> dict | list:
        req = urllib.request.Request(
            f"{_BASE_URL}{path}",
            headers={"x-api-key": self._api_key},
        )
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read())

    def fetch_all_statuses(self) -> list[DeviceStatus]:
        now = datetime.now(timezone.utc)
        statuses = []
        for uuid in self._device_uuids:
            status = self._get(f"/sesame2/{uuid}")
            statuses.append(
                DeviceStatus(
                    device_uuid=uuid,
                    nickname=uuid,
                    locked=status["CHSesame2Status"] == "locked",
                    battery=status["batteryPercentage"],
                    timestamp=now,
                )
            )
        return statuses
