package com.devkev.main;

import java.io.IOException;

/**@author Philipp Gersch*/
public class Main {
	
	public static Server handler;
	
	public static void main(String[] args) throws IOException {
		handler = new Server(10, 10000);
		handler.listen();
	}
	
}
