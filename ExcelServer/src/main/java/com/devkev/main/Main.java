package com.devkev.main;

import java.io.IOException;

/**@author Philipp Gersch*/
public class Main {
	
	public static Server handler;
	public static Logger logger;
	
	public static void main(String[] args) throws IOException  {
		
		if(args.length < 2) {
			throw new IllegalArgumentException("Expecting arguments: <max-connections> <connection-timeout (milliseconds)>");
		}
		
		logger = new Logger();
		//Nervige "Fehlende Log4j Klasse" Fehlermeldung ausschalten ...
		//StatusLogger.getLogger().setLevel(Level.OFF);
		
		handler = new Server(Integer.parseInt(args[0]), Integer.parseInt(args[1]));
		handler.listen();
	}
	
}
