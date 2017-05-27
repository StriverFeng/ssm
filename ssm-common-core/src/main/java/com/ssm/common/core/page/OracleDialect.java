package com.ssm.common.core.page;

public class OracleDialect extends AbstractDialect {

    private static final String LIMIT_REPLACEMENT_TEMPLATE = "SELECT * FROM (SELECT ROWNUM rownum_, row_.* FROM (%s) row_ WHERE ROWNUM <= %d) WHERE rownum_ > %d";

    @Override
    protected String getLimitQueryString(String sql, int offset, int limit) {
        return String.format(LIMIT_REPLACEMENT_TEMPLATE, sql, limit, offset > 1 ? offset - 1 : 0);
    }

}
