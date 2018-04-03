# Gigo

A module for tracing black-box functions

This is intended to be the fastest way to achieve a high degree fo code coverage in tests.

This will generate mock data from live runs of an existing module and help you throw together a complete suite of black-box tests.

It is aimed at API clients, and includes tracing calls to Invoke-RestMethod, so that the API call can be mocked out easily.