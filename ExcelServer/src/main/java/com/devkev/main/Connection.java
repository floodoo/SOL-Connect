package com.devkev.main;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.Socket;

public class Connection  {
	
	public static long SESSION_COUNTER = 0;
	
	public final long sessionId;
	
	public long startTime;
	
	public final Socket client;
	public final BufferedWriter writer;
	
	public Thread thread;
	
	public Connection(Socket client) throws IOException {
		this.sessionId = SESSION_COUNTER;
		this.client = client;
		this.writer = new BufferedWriter(new OutputStreamWriter(client.getOutputStream()));
		
		SESSION_COUNTER++;
	}
	
	public void addThread(Thread thread) {
		this.thread = thread;
	}
	
	public synchronized void activate() {
		this.startTime = System.currentTimeMillis();
		this.thread.start();
	}
}
