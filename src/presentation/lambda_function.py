import os

from application.use_cases.collect_status import CollectStatusUseCase
from infrastructure.elasticsearch.client import ElasticsearchClient
from infrastructure.sesame.client import SesameApiClient


def handler(event: dict, context: object) -> dict:
    use_case = CollectStatusUseCase(
        device_repo=SesameApiClient(api_key=os.environ["SESAME_API_KEY"]),
        status_repo=ElasticsearchClient(
            host=os.environ["ELASTICSEARCH_HOST"],
            port=int(os.environ.get("ELASTICSEARCH_PORT", "9200")),
        ),
    )
    use_case.execute()
    return {"statusCode": 200, "body": "OK"}
