# ADR-002: Use Hub-and-Spoke Networking

## Status
Proposed

## Context
GASOC requires centralized connectivity, routing, inspection, and segmentation for Azure workloads.

## Decision
A hub-and-spoke topology will be used. The hub will contain shared network services. Workload VNets will peer to the hub.

## Consequences
- Centralized control of firewall, VPN, DNS, and shared services.
- Workload isolation through separate spokes.
- Enables phased growth while controlling cost.
