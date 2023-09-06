package com.example.pro;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.*;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import io.flutter.embedding.android.FlutterActivity;

import static com.wireguard.android.backend.Tunnel.State.UP;
import android.content.Intent;
import android.os.Bundle;
import android.os.AsyncTask;
import com.wireguard.android.backend.Backend;
import com.wireguard.android.backend.GoBackend;
import com.wireguard.android.backend.Tunnel;
import com.wireguard.config.Config;
import com.wireguard.config.InetEndpoint;
import com.wireguard.config.InetNetwork;
import com.wireguard.config.Interface;
import com.wireguard.config.Peer;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "wireguard";
    Tunnel tunnel = new WgTunnel();;
    Intent intentPrepare;
    Interface.Builder interfaceBuilder;
    Peer.Builder peerBuilder;
    Backend backend;
    public void connect(Object config) {
        java.util.ArrayList list = (java.util.ArrayList)config;
        System.out.println(list);
        System.out.println((String)list.get(3));
        intentPrepare = GoBackend.VpnService.prepare(this);
        if(intentPrepare != null) {
            startActivityForResult(intentPrepare, 0);
        }
        interfaceBuilder = new Interface.Builder();
        peerBuilder = new Peer.Builder();
        backend = new GoBackend(this);
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    backend.setState(tunnel, UP, new Config.Builder()
                            .setInterface(interfaceBuilder.addAddress(InetNetwork.parse((String)list.get(0))).parsePrivateKey((String)list.get(1)).setListenPort(51820).addDnsSearchDomain((String)list.get(4)).build())
                            .addPeer(peerBuilder.addAllowedIp(InetNetwork.parse("0.0.0.0/0")).setEndpoint(InetEndpoint.parse((String)list.get(2))).parsePublicKey((String)list.get(3)).build())
                            .build());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

     public void disconnect(){
         AsyncTask.execute(new Runnable() {
             @Override
             public void run() {
                 try {
                     backend.setState(tunnel,Tunnel.State.DOWN,null);
                 } catch (Exception e) {
                     e.printStackTrace();
                 }
             }
         });
     }


    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if(call.method.equals("wg_up")){
                                connect(call.arguments);
                            }
                            if(call.method.equals("wg_down")){
                                disconnect();
                            }
                        }
                );
    }
}