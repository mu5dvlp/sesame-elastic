import json
import urllib.request

from domain.models.device_status import DeviceStatus
from domain.repositories.status_repository import StatusRepository

_INDEX = "sesame-status"


class ElasticsearchClient(StatusRepository):
    def __init__(self, host: str, port: int) -> None:
        self._base_url = f"http://{host}:{port}"

    def save(self, status: DeviceStatus) -> None:
        doc = {
            "device_uuid": status.device_uuid,
            "nickname": status.nickname,
            "locked": status.locked,
            "battery": status.battery,
            "responsive": status.responsive,
            "@timestamp": status.timestamp.isoformat(),
        }
        data = json.dumps(doc).encode()
        req = urllib.request.Request(
            f"{self._base_url}/{_INDEX}/_doc",
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req):
            pass
