/**
  * FireCloud
  * Genome analysis execution service.
  *
  * OpenAPI spec version: 0.1
  *
  *
  * NOTE: This class is auto generated by the swagger code generator program.
  * https://github.com/swagger-api/swagger-codegen.git
  * Do not edit the class manually.
  */
package org.broadinstitute.dsp.pipelines.firecloud.model.autogen

case class ErrorReport(
    /* service causing error */
    source: String,
    /* what went wrong */
    message: String,
    /* HTTP status code */
    statusCode: Option[Integer] = None,
    /* errors triggering this one */
    causes: List[ErrorReport],
    /* stack trace */
    stackTrace: List[StackTraceElement]
)
