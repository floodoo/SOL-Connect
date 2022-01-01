package com.devkev.main;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

import com.devkev.api.commands.Commands;
import com.devkev.devscript.raw.Output;
import com.devkev.devscript.raw.Process;
import static com.devkev.main.Logger.logError;
import static com.devkev.main.Logger.log;

public class Server {
	
	private final int LISTEN_PORT = 6969;
	private ServerSocket listenSocket = null;
	
	private final int MAX_CONNECTIONS;
	private final long MAX_CONNECTION_TIME;
	
	private ArrayList<Connection> activeClients = new ArrayList<>();
	private Thread gateway;
	
	
	/**@param maxConnections - Maximal Anzahl an Clients die sich verbinden dürfen.
	 * @param maxConnectionTime - Maximale Zeit, die ein Client verbunden sein darf. In Millisekunden*/
	public Server(int maxConnections, int maxConnectionTime) {
		
		if(maxConnections <= 0) maxConnections = -1;
		if(maxConnectionTime <= 0) maxConnectionTime = -1;
		
		System.out.println("Picked up options: MaxClientConnections=" + maxConnections + ", MaxConnectionTime=" + maxConnectionTime / 1000 + " seconds\n---");
		
		this.MAX_CONNECTIONS = maxConnections;
		this.MAX_CONNECTION_TIME = maxConnectionTime;
	}
	
	private void addClientConnection(Socket client) throws IOException {
		final Connection c = new Connection(client);
		
		//System.out.println("Starting session: " + c.sessionId);
		
		c.addThread(new Thread(new Runnable() {
			@Override
			public void run() {				
				//Maximal einen Command pro connection!
				try {
					Process commandHandler = new Process(true);
					BufferedReader reader = new BufferedReader(new InputStreamReader(c.client.getInputStream()));
					
					//Einfach eine Zeile!
					String command = reader.readLine();
					commandHandler.clearLibraries();
					commandHandler.includeLibrary(new Commands());
					commandHandler.setVariable("connection", c, true, true);
					commandHandler.addOutput(new Output() {
						@Override
						public void warning(String arg0) {
						}
						@Override
						public void log(String arg0, boolean arg1) {
						}
						@Override
						public void error(String arg0) {
							logError("Error while executing command: " + command + ": " + arg0);
							c.status = 1;
						}
					});
					commandHandler.execute(command, false);
				} catch (IOException e) {
					c.status = 1;
					e.printStackTrace();
				}
				
				closeConnection(c);
				
				if(c.status == 1) {
					logError("Closed session " + c.sessionId + " (" + (c.status == 0 ? "SUCCESS" : "ERROR") + ")");
					log(activeClients.size() + " active connections.");
				}
				
			}
		}));
		
		activeClients.add(c);
		c.activate();
	}
	
	private void closeConnection(Connection c) {
		try {
			c.client.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		activeClients.remove(c);
		
		if(activeClients.size() < MAX_CONNECTIONS) {
			//Ein Platz ist wieder frei geworden!
			synchronized (gateway) {
				gateway.notify();
			}
		}
	}
	
	public void listen() throws IOException {
		if(listenSocket != null) return;
		
		listenSocket = new ServerSocket(LISTEN_PORT);
		listenSocket.setReuseAddress(true);
		
		System.out.println("Version: 1.0.1\n");
		System.out.println("Listening on " + LISTEN_PORT);
		
		if(MAX_CONNECTIONS > 0) {
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					while(true) {
						
						synchronized (this) {
							try {
								wait(1000);
							} catch (InterruptedException e) {
								e.printStackTrace();
							}
						}
						
						long currentTime = System.currentTimeMillis();
						
						for(int i = 0; i < activeClients.size(); i++) {
							if(currentTime - activeClients.get(i).startTime > MAX_CONNECTION_TIME) {
								//Wirf den client raus
								logError("Client exceeded max connection time! Kicking SessionID: " + activeClients.get(i).sessionId);
								activeClients.get(i).status = 1;
								
								//Sende eine Nachricht bevor die Verbindung geschlossen wird
								try {
									activeClients.get(i).writer.write("{\"message\": \"Connection timeout (" + (MAX_CONNECTION_TIME / 1000) + " sec)\"}");
									activeClients.get(i).writer.flush();
								} catch (IOException e) {
									logError("Failed to send abort message ...");
								}
					    		
								closeConnection(activeClients.get(i));
								i--;
							}
						}
					}
				}
			}, "timeout-observer").start();
		}
		
		gateway = new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					while(true) {
						Socket connectionSocket = listenSocket.accept();
						
						try {
							addClientConnection(connectionSocket);
						} catch(Exception e) {
							logError("Failed to establish an open connection to client.");
						}
						
						if(MAX_CONNECTIONS > 0) {
							//Friere den Gateway ein, wenn zu viele Verbindungen gleichzeitig aufgebaut wurden
							if(activeClients.size() >= MAX_CONNECTIONS) {
								try {
									logError("Exceeded max connections! " + MAX_CONNECTIONS + " Waiting for more space ...");
									synchronized (gateway) {
										gateway.wait();
									}
								} catch (InterruptedException e) {
									e.printStackTrace();
								}
							}
						}
					}
			} catch(Exception e) {
				e.printStackTrace();
			} finally {
				try {
					listenSocket.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		}, "StateListener");
		gateway.start();
	}
}
