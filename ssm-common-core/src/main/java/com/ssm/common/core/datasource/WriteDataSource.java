package com.ssm.common.core.datasource;

import com.ssm.common.base.util.EncryptUtils;
import org.apache.commons.dbcp2.BasicDataSource;

public class WriteDataSource extends BasicDataSource {

    private static final long serialVersionUID = 20160117L;

    /**
     * @param password encrypt password
     */
    @Override
    public void setPassword(String password) {
        super.setPassword(EncryptUtils.decrypt(password, EncryptUtils.DEFAULT_KEY));
    }

}
