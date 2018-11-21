/* Copyright (c) 2001-2011, The HSQL Development Group
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * Neither the name of the HSQL Development Group nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL HSQL DEVELOPMENT GROUP, HSQLDB.ORG,
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


package org.hsqldb;

import org.hsqldb.lib.IntKeyHashMap;
import org.hsqldb.lib.IntValueHashMap;
import org.hsqldb.lib.OrderedIntHashSet;

/**
 * Defines and enumerates reserved and non-reserved SQL keywords.<p>
 *
 * @author Fred Toussi (fredt@users dot sourceforge.net)
 * @version 2.3.0
 * @since 1.7.2
 */
public class Tokens {

    // SQL 200n reserved words full set
    static final String        T_ABS              = "ABS";
    public static final String T_ALL              = "ALL";
    static final String        T_ALLOCATE         = "ALLOCATE";
    public static final String T_ALTER            = "ALTER";
    static final String        T_AND              = "AND";
    public static final String T_ANY              = "ANY";
    static final String        T_ARE              = "ARE";
    public static final String T_ARRAY            = "ARRAY";
    public static final String T_ARRAY_AGG        = "ARRAY_AGG";
    public static final String T_AS               = "AS";
    static final String        T_ASENSITIVE       = "ASENSITIVE";
    static final String        T_ASYMMETRIC       = "ASYMMETRIC";
    static final String        T_AT               = "AT";
    static final String        T_ATOMIC           = "ATOMIC";
    public static final String T_AUTHORIZATION    = "AUTHORIZATION";
    public static final String T_AVG              = "AVG";
    static final String        T_BEGIN            = "BEGIN";
    static final String        T_BETWEEN          = "BETWEEN";
    public static final String T_BIGINT           = "BIGINT";
    public static final String T_BINARY           = "BINARY";
    static final String        T_BIT_LENGTH       = "BIT_LENGTH";
    public static final String T_BLOB             = "BLOB";
    public static final String T_BOOLEAN          = "BOOLEAN";
    static final String        T_BOTH             = "BOTH";
    static final String        T_BY               = "BY";
    public static final String T_CALL             = "CALL";
    static final String        T_CALLED           = "CALLED";
    static final String        T_CARDINALITY      = "CARDINALITY";
    public static final String T_CASCADED         = "CASCADED";
    static final String        T_CASE             = "CASE";
    static final String        T_CAST             = "CAST";
    static final String        T_CEIL             = "CEIL";
    static final String        T_CEILING          = "CEILING";
    public static final String T_CHAR             = "CHAR";
    static final String        T_CHAR_LENGTH      = "CHAR_LENGTH";
    public static final String T_CHARACTER        = "CHARACTER";
    static final String        T_CHARACTER_LENGTH = "CHARACTER_LENGTH";
    public static final String T_CHECK            = "CHECK";
    public static final String T_CLOB             = "CLOB";
    static final String        T_CLOSE            = "CLOSE";
    static final String        T_COALESCE         = "COALESCE";
    public static final String T_COLLATE          = "COLLATE";
    static final String        T_COLLECT          = "COLLECT";
    static final String        T_COLUMN           = "COLUMN";
    public static final String T_COMMIT           = "COMMIT";
    static final String        T_CONDITION        = "CONDIITON";
    public static final String T_CONNECT          = "CONNECT";
    public static final String T_CONSTRAINT       = "CONSTRAINT";
    public static final String T_CONVERT          = "CONVERT";
    static final String        T_CORR             = "CORR";
    static final String        T_CORRESPONDING    = "CORRESPONDING";
    static final String        T_COUNT            = "COUNT";
    static final String        T_COVAR_POP        = "COVAR_POP";
    static final String        T_COVAR_SAMP       = "COVAR_SAMP";
    public static final String T_CREATE           = "CREATE";
    static final String        T_CROSS            = "CROSS";
    static final String        T_CUBE             = "CUBE";
    static final String        T_CUME_DIST        = "CUME_DIST";
    static final String        T_CURRENT          = "CURRENT";
    static final String        T_CURRENT_CATALOG  = "CURRENT_CATALOG";
    static final String        T_CURRENT_DATE     = "CURRENT_DATE";
    static final String T_CURRENT_DEFAULT_TRANSFORM_GROUP =
        "CURRENT_DEFAULT_TRANSFORM_GROUP";
    static final String T_CURRENT_PATH      = "CURRENT_PATH";
    static final String T_CURRENT_ROLE      = "CURRENT_ROLE";
    static final String T_CURRENT_SCHEMA    = "CURRENT_SCHEMA";
    static final String T_CURRENT_TIME      = "CURRENT_TIME";
    static final String T_CURRENT_TIMESTAMP = "CURRENT_TIMESTAMP";
    static final String T_CURRENT_TRANSFORM_GROUP_FOR_TYPE =
        "CURRENT_TRANSFORM_GROUP_FOR_TYPE";
    static final String        T_CURRENT_USER      = "CURRENT_USER";
    static final String        T_CURSOR            = "CURSOR";
    static final String        T_CYCLE             = "CYCLE";
    public static final String T_DATE              = "DATE";
    public static final String T_DAY               = "DAY";
    static final String        T_DEALLOCATE        = "DEALLOCATE";
    public static final String T_DEC               = "DEC";
    public static final String T_DECIMAL           = "DECIMAL";
    static final String        T_DECLARE           = "DECLARE";
    public static final String T_DEFAULT           = "DEFAULT";
    public static final String T_DELETE            = "DELETE";
    static final String        T_DENSE_RANK        = "DENSE_RANK";
    static final String        T_DEREF             = "DEREF";
    static final String        T_DESCRIBE          = "DESCRIBE";
    static final String        T_DETERMINISTIC     = "DETERMINISTIC";
    static final String        T_DISCONNECT        = "DISCONNECT";
    static final String        T_DISTINCT          = "DISTINCT";
    public static final String T_DO                = "DO";
    public static final String T_DOUBLE            = "DOUBLE";
    static final String        T_DROP              = "DROP";
    static final String        T_DYNAMIC           = "DYNAMIC";
    static final String        T_EACH              = "EACH";
    static final String        T_ELEMENT           = "ELEMENT";
    static final String        T_ELSE              = "ELSE";
    static final String        T_ELSEIF            = "ELSEIF";
    static final String        T_END               = "END";
    static final String        T_END_EXEC          = "END_EXEC";
    static final String        T_ESCAPE            = "ESCAPE";
    static final String        T_EVERY             = "EVERY";
    static final String        T_EXCEPT            = "EXCEPT";
    static final String        T_EXEC              = "EXEC";
    public static final String T_EXECUTE           = "EXECUTE";
    static final String        T_EXISTS            = "EXISTS";
    static final String        T_EXP               = "EXP";
    public static final String T_EXTERNAL          = "EXTERNAL";
    static final String        T_EXTRACT           = "EXTRACT";
    public static final String T_FALSE             = "FALSE";
    static final String        T_FETCH             = "FETCH";
    static final String        T_FILTER            = "FILTER";
    static final String        T_FIRST_VALUE       = "FIRST_VALUE";
    public static final String T_FLOAT             = "FLOAT";
    static final String        T_FLOOR             = "FLOOR";
    public static final String T_FOR               = "FOR";
    public static final String T_FOREIGN           = "FOREIGN";
    static final String        T_FREE              = "FREE";
    public static final String T_FROM              = "FROM";
    static final String        T_FULL              = "FULL";
    public static final String T_FUNCTION          = "FUNCTION";
    static final String        T_FUSION            = "FUSION";
    public static final String T_GET               = "GET";
    static final String        T_GLOBAL            = "GLOBAL";
    public static final String T_GRANT             = "GRANT";
    static final String        T_GROUP             = "GROUP";
    static final String        T_GROUPING          = "GROUPING";
    static final String        T_HANDLER           = "HANDLER";
    static final String        T_HAVING            = "HAVING";
    static final String        T_HOLD              = "HOLD";
    public static final String T_HOUR              = "HOUR";
    static final String        T_IDENTITY          = "IDENTITY";
    static final String        T_IF                = "IF";
    static final String        T_IMPORT            = "IMPORT";
    static final String        T_IN                = "IN";
    static final String        T_INDICATOR         = "INDICATOR";
    static final String        T_INNER             = "INNER";
    static final String        T_INOUT             = "INOUT";
    static final String        T_INSENSITIVE       = "INSENSITIVE";
    public static final String T_INSERT            = "INSERT";
    public static final String T_INT               = "INT";
    public static final String T_INTEGER           = "INTEGER";
    static final String        T_INTERSECT         = "INTERSECT";
    static final String        T_INTERSECTION      = "INTERSECTION";
    public static final String T_INTERVAL          = "INTERVAL";
    static final String        T_INTO              = "INTO";
    static final String        T_ITERATE           = "ITERATE";
    public static final String T_IS                = "IS";
    static final String        T_JAR               = "JAR";              // SQL/JRT
    static final String        T_JOIN              = "JOIN";
    static final String        T_LAG               = "LAG";
    public static final String T_LANGUAGE          = "LANGUAGE";
    static final String        T_LARGE             = "LARGE";
    static final String        T_LAST_VALUE        = "LAST_VALUE";
    static final String        T_LATERAL           = "LATERAL";
    static final String        T_LEAD              = "LEAD";
