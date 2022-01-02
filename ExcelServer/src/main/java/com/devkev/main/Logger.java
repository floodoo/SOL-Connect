package com.devkev.main;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Logger {
	
	private static final DateFormat format = new SimpleDateFormat("dd.MM.yyyy-HH:mm:ss");
	
	public static void logError(String message) {
		System.err.println("[" + format.format(new Date(System.currentTimeMillis())) + "] " + message);
	}
	
	public static void log(String message) {
		System.out.println("[" + format.format(new Date(System.currentTimeMillis())) + "] " + message);
	}
}
