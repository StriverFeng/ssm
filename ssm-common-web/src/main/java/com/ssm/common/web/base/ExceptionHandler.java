package com.ssm.common.web.base;

import com.ssm.common.exception.AbstractException;
import com.ssm.common.exception.UnknownException;
import com.ssm.common.util.Constant;
import com.ssm.common.web.data.ResponseData;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

/**
 * 异常统一处理的三种方式:
 * (1)使用@ExceptionHandler注解: 异常处理方法必须与出错方法在同一个Controller里面, 每个Controller都要写一遍;
 * (2)实现HandlerExceptionResolver接口: 只要实现HandlerExceptionResolver接口就是全局异常解析器;
 * (3)使用@ControllerAdvice注解: @ControllerAdvice+@ExceptionHandler注解解决了异常处理方法必须与出错方法在同一个Controller里面的问题, 可以实现全局异常.
 */
@ControllerAdvice
public class ExceptionHandler extends ResponseEntityExceptionHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(ExceptionHandler.class);

    @ResponseBody
    @org.springframework.web.bind.annotation.ExceptionHandler(AbstractException.class)
    public ResponseData handleApplicationException(AbstractException ex) {
        return new ResponseData()
                .setSuccess(Boolean.FALSE)
                .setCode(ex.getErrorCode())
                .setMessage(ex.getMessage());
    }

    @ResponseBody
    @org.springframework.web.bind.annotation.ExceptionHandler(RuntimeException.class)
    public ResponseData handleApplicationException(RuntimeException ex) {
        LOGGER.error(ex.getMessage(), ex);
        AbstractException exception = new UnknownException(ex);
        return new ResponseData()
                .setSuccess(Boolean.FALSE)
                .setCode(exception.getErrorCode())
                .setMessage(exception.getMessage());
    }

    @org.springframework.web.bind.annotation.ExceptionHandler(Exception.class)
    public String handleApplicationException(Exception ex, WebRequest request) {
        LOGGER.error(ex.getMessage(), ex);
        request.setAttribute(Constant.EXCEPTION_ATTRIBUTE, ex.getMessage(), RequestAttributes.SCOPE_REQUEST);
        return "forward:/error/exception.jsp";
    }

    // @org.springframework.web.bind.annotation.ExceptionHandler(Throwable.class)
    // public String handleApplicationException(Throwable ex, WebRequest request) {
    //     LOGGER.error(ex.getMessage(), ex);
    //     return "redirect:/error/error.jsp";
    // }

}
