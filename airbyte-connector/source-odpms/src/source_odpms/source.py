#
# Copyright (c) 2023 Airbyte, Inc., all rights reserved.
#

from abc import ABC
from typing import Any, Iterable, List, Mapping, MutableMapping, Optional, Tuple

import requests
from airbyte_cdk.sources import AbstractSource
from airbyte_cdk.sources.streams import Stream
from airbyte_cdk.sources.streams.http import HttpStream
from airbyte_cdk.sources.streams.http.auth import TokenAuthenticator

import zipfile
from io import BytesIO
import pandas as pd
from json import loads

# Basic full refresh stream
class OdpmsStream(HttpStream, ABC):

    url_base = "https://opentransportdata.swiss/en/dataset/"

    def next_page_token(self, response: requests.Response) -> Optional[Mapping[str, Any]]:
        return None

    def request_params(
        self, stream_state: Mapping[str, Any], stream_slice: Mapping[str, any] = None, next_page_token: Mapping[str, Any] = None
    ) -> MutableMapping[str, Any]:
        return {}

    def parse_response(self, response: requests.Response, **kwargs) -> Iterable[Mapping]:
        yield {}
    
class Agency(OdpmsStream):

    primary_key = "agency_id"

    def path(
        self, stream_state: Mapping[str, Any] = None, stream_slice: Mapping[str, Any] = None, next_page_token: Mapping[str, Any] = None
    ) -> str:
        return "timetable-2024-gtfs2020/permalink"
    
    def parse_response(self, response: requests.Response, **kwargs) -> Iterable[Mapping]:
        with zipfile.ZipFile(BytesIO(response.content)) as thezip:
            with thezip.open("agency.txt") as f:
                json_str = pd.read_csv(f).to_json(orient='records', lines=False)
                records = loads(json_str)
        return records

class Routes(OdpmsStream):

    primary_key = "route_id"

    def path(
        self, stream_state: Mapping[str, Any] = None, stream_slice: Mapping[str, Any] = None, next_page_token: Mapping[str, Any] = None
    ) -> str:
        return "timetable-2024-gtfs2020/permalink"

    def parse_response(self, response: requests.Response, **kwargs) -> Iterable[Mapping]:
        with zipfile.ZipFile(BytesIO(response.content)) as thezip:
            with thezip.open("routes.txt") as f:
                json_str = pd.read_csv(f).to_json(orient='records', lines=False)
                records = loads(json_str)
        return records

# Source
class SourceOdpms(AbstractSource):
    def check_connection(self, logger, config) -> Tuple[bool, any]:
        return True, None

    def streams(self, config: Mapping[str, Any]) -> List[Stream]:
        auth = TokenAuthenticator(token="api_key")  
        return [Agency(authenticator=auth), Routes(authenticator=auth)]
