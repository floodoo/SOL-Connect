package com.devkev.main;

import java.net.Socket;

public class Connection  {
	
	public static long SESSION_COUNTER = 0;
	
	public final long sessionId;
	
	public long startTime;
	
	public final Socket client;
	
	public Thread thread;
	
	public Connection(Socket client) {
		this.sessionId = SESSION_COUNTER;
		this.client = client;
		
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
