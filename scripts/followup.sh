#!/bin/bash

curl -X POST 'Content-Type: application/json' -H "Session-Token: 6ufe8r5mi3i0kq9b9c63mj2vg8" -d '{"input": {"ticket_id": "64", "is_private": "1", "requesttypes_id": "1", "content": "test_suivi"}}' http://192.168.158.129:8080/apirest.php/Ticket/76/TicketFollowup/
