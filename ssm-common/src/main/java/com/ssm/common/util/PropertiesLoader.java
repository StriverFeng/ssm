package com.ssm.common.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.ResourceLoader;
import org.springframework.core.io.support.PropertiesLoaderUtils;

import java.io.IOException;
import java.util.Properties;
import java.util.Set;

public abstract class PropertiesLoader {

    private static final Logger LOGGER = LoggerFactory.getLogger(PropertiesLoader.class);

    private static final Properties properties = new Properties();

    public static void init(String... resources) {
        loadProperties(resources);
    }

    private static void loadProperties(String... resources) {
        ResourceLoader resourceLoader = new DefaultResourceLoader();
        for (String location : resources) {
            try {
                LOGGER.debug("Loading properties file from {}", location);
                PropertiesLoaderUtils.fillProperties(properties, resourceLoader.getResource(location));
            } catch (IOException e) {
                LOGGER.warn("Could not load properties from path {}", location, e);
            }
        }
    }

    private static String getValue(String key) {
        // String value = System.getProperty(key);
        // if (value != null) {
        //     return value;
        // }
        return properties.getProperty(key);
    }

    private static String getValue(String key, String defaultValue) {
        String value = getValue(key);
        return value != null ? value : defaultValue;
    }

    public static String getValue(Config config) {
        return getValue(config.getValue());
    }

    public static String getValue(Config config, String defaultValue) {
        String value = getValue(config);
        return value != null ? value : defaultValue;
    }

    public static Integer getInteger(Config config) {
        return Integer.valueOf(getValue(config));
    }

    public static Integer getInteger(Config config, Integer defaultValue) {
        Integer value = getInteger(config);
        return value != null ? value : defaultValue;
    }

    public static Boolean getBoolean(Config config) {
        return Boolean.valueOf(getValue(config));
    }

    public static Boolean getBoolean(Config config, Boolean defaultValue) {
        Boolean value = getBoolean(config);
        return value != null ? value : defaultValue;
    }

    public static Set<String> getKeys() {
        return properties.stringPropertyNames();
    }

    public static Properties getProperties() {
        return properties;
    }

    public enum Config {

        PHASE_ENV("phaseEnv"),
        PAGE_SIZE("pageSize"),
        USE_CAPTCHA("useCaptcha"),
        DATE_FORMAT("dateFormat"),
        DATETIME_FORMAT("datetimeFormat"),
        COMPANY_NAME("companyName"),
        PROJECT_NAME("projectName");

        private final String value;

        Config(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }

    }

}
