package com.example.pro;

import com.wireguard.android.backend.Tunnel;

public class WgTunnel implements Tunnel {
    @Override
    public String getName() {
        return "pro";
    }

    @Override
    public void onStateChange(State newState) {
    }
}