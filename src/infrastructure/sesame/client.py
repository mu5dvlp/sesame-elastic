import json
import urllib.error
import urllib.request
from datetime import datetime, timezone

from domain.models.device_status import DeviceStatus
from domain.repositories.device_repository import DeviceRepository

_BASE_URL = "https://api.candyhouse.co/public"


class SesameApiClient(DeviceRepository):
    def __init__(self, api_key: str) -> None:
        self._api_key = api_key

    def _get(self, path: str) -> dict | list:
        req = urllib.request.Request(
            f"{_BASE_URL}{path}",
            headers={"Authorization": self._api_key},
        )
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read())

    def fetch_all_statuses(self) -> list[DeviceStatus]:
        devices = self._get("/sesames")
        now = datetime.now(timezone.utc)
        statuses = []
        for device in devices:
            uuid = device["device_uuid"]
            status = self._get(f"/sesame/{uuid}")
            statuses.append(
                DeviceStatus(
                    device_uuid=uuid,
                    nickname=device.get("nickname", ""),
                    locked=status["locked"],
                    battery=status["battery"],
                    responsive=status["responsive"],
                    timestamp=now,
                )
            )
        return statuses
