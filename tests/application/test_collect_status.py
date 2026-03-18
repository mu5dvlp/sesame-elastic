from datetime import datetime, timezone
from unittest.mock import MagicMock

import pytest

from application.use_cases.collect_status import CollectStatusUseCase
from domain.models.device_status import DeviceStatus


def _make_status(**kwargs) -> DeviceStatus:
    defaults = dict(
        device_uuid="uuid-1",
        nickname="Front Door",
        locked=True,
        battery=80,
        responsive=True,
        timestamp=datetime(2026, 1, 1, tzinfo=timezone.utc),
    )
    return DeviceStatus(**{**defaults, **kwargs})


def test_saves_all_statuses():
    status = _make_status()
    device_repo = MagicMock()
    device_repo.fetch_all_statuses.return_value = [status]
    status_repo = MagicMock()

    CollectStatusUseCase(device_repo, status_repo).execute()

    status_repo.save.assert_called_once_with(status)


def test_multiple_devices():
    statuses = [_make_status(device_uuid=f"uuid-{i}") for i in range(3)]
    device_repo = MagicMock()
    device_repo.fetch_all_statuses.return_value = statuses
    status_repo = MagicMock()

    CollectStatusUseCase(device_repo, status_repo).execute()

    assert status_repo.save.call_count == 3


def test_empty_device_list():
    device_repo = MagicMock()
    device_repo.fetch_all_statuses.return_value = []
    status_repo = MagicMock()

    CollectStatusUseCase(device_repo, status_repo).execute()

    status_repo.save.assert_not_called()
