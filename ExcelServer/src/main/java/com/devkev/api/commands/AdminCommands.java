package com.devkev.api.commands;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;

import com.devkev.devscript.raw.Block;
import com.devkev.devscript.raw.Command;
import com.devkev.devscript.raw.Library;
import com.devkev.devscript.raw.Process;
import com.devkev.main.Main;

public class AdminCommands extends Library {

	public AdminCommands() {
		super("Admin Commands");
	}

	@Override
	public Command[] createLib() {
		return new Command[] {
				
				new Command("help", "", "") {
					@Override
					public Object execute(Object[] arg0, Process arg1, Block arg2) throws Exception {
						System.out.println("\nhelp\t\t: Liste von Befehlen"
								+ "\n. <string>\t: Führt einen Shell Befehl aus. Z.B. '. ls -l -a'\n"
								+ "kill\t\t: Fährt den Server schonend herunter.\n\nTipp: benutze '. cat instancelog.log' um den log anzuschauen!\n");
						return null;
					}
				},
				
//				new Command("log", "string ...", "") {
//					@Override
//					public Object execute(Object[] arg0, Process arg1, Block arg2) throws Exception {
//						int count = 10;
//						if(arg0.length > 0) {
//							count = Integer.valueOf(arg0[0].toString());
//						}
//						
//						ArrayList<String> lines = new ArrayList<String>();
//						BufferedReader reader = new BufferedReader(new FileReader(Main.logger.logFile));
//						String logLine = Main.logger.fileReader.readLine();
//						while(true) {
//							System.out.println(logLine);
//							lines.add(logLine);
//							logLine = Main.logger.fileReader.readLine();
//							if(logLine == null) break;
//						}
//						for(int i = lines.size()-1; i >= lines.size()-count; i--) {
//							if(i >= 0) {
//								System.out.println(lines.get(i));
//							} else break;
//						}
//						return null;
//					}
//				},
				
				new Command("kill", "", "Führt einen Shell Befehl aus") {
					@Override
					public Object execute(Object[] arg0, Process arg1, Block arg2) throws Exception {
						arg1.log("Stopped", false);
						System.exit(0);
						return null;
					}
				},
				
				new Command(".", "string ...", "Führt einen Shell Befehl aus") {
					@Override
					public Object execute(Object[] arg0, Process arg1, Block arg2) throws Exception {
						String all = "";
						for(Object s : arg0) {
							all += " " + s.toString();
						}
						Process sub = new Process(true);
						sub.addSystemOutput();
						sub.execute("exec <" + all + ">", false);
						return null;
					}
				}
		};
	}

}
