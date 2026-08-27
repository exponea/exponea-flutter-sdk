package com.exponea.data

import com.exponea.sdk.models.ContentBlockSelector
import com.exponea.sdk.models.InAppContentBlock
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeoutException
import com.exponea.sdk.util.Logger

class FlutterContentBlockCarouselSelector(
    private val filterCallback: ((List<InAppContentBlock>) -> Unit)? = null,
    private val sortCallback: ((List<InAppContentBlock>) -> Unit)? = null,
    responseTimeoutMillis: Long? = null,
) : ContentBlockSelector() {
    companion object {
        private const val DEFAULT_RESPONSE_TIMEOUT_MILLIS = 250L
    }

    private val responseTimeoutMillis = responseTimeoutMillis?.takeIf { it > 0 }
        ?: DEFAULT_RESPONSE_TIMEOUT_MILLIS
    private var filterResponse: CompletableFuture<List<InAppContentBlock>>? = null
    private var sortResponse: CompletableFuture<List<InAppContentBlock>>? = null

    init {
        if (responseTimeoutMillis != null && responseTimeoutMillis <= 0) {
            Logger.w(
                this,
                "InAppCbCarousel: responseTimeoutMillis must be positive; using ${DEFAULT_RESPONSE_TIMEOUT_MILLIS} ms."
            )
        }
    }

    override fun filterContentBlocks(source: List<InAppContentBlock>): List<InAppContentBlock> {
        if (filterCallback != null) {
            val response = prepareFilterResponse()
            try {
                filterCallback.invoke(source)
                return response.get(responseTimeoutMillis, TimeUnit.MILLISECONDS)
            } catch (_: TimeoutException) {
                // Fall back to the SDK's native filter.
            } catch (e: Exception) {
                Logger.e(this, "InAppCbCarousel: Custom filter failed, invoking original behaviour", e)
            } finally {
                clearFilterResponse(response)
            }
        }
        return super.filterContentBlocks(source)
    }

    override fun sortContentBlocks(source: List<InAppContentBlock>): List<InAppContentBlock> {
        if (sortCallback != null) {
            val response = prepareSortResponse()
            try {
                sortCallback.invoke(source)
                return response.get(responseTimeoutMillis, TimeUnit.MILLISECONDS)
            } catch (_: TimeoutException) {
                // Fall back to the SDK's native sort.
            } catch (e: Exception) {
                Logger.e(this, "InAppCbCarousel: Custom sort failed, invoking original behaviour", e)
            } finally {
                clearSortResponse(response)
            }
        }
        return super.sortContentBlocks(source)
    }

    @Synchronized
    private fun prepareFilterResponse(): CompletableFuture<List<InAppContentBlock>> {
        // cancel previous awaiting
        filterResponse?.cancel(true)
        return CompletableFuture<List<InAppContentBlock>>().also {
            this.filterResponse = it
        }
    }

    @Synchronized
    private fun prepareSortResponse(): CompletableFuture<List<InAppContentBlock>> {
        // cancel previous awaiting
        sortResponse?.cancel(true)
        return CompletableFuture<List<InAppContentBlock>>().also {
            this.sortResponse = it
        }
    }

    @Synchronized
    private fun clearFilterResponse(response: CompletableFuture<List<InAppContentBlock>>) {
        if (filterResponse === response) {
            filterResponse = null
        }
    }

    @Synchronized
    private fun clearSortResponse(response: CompletableFuture<List<InAppContentBlock>>) {
        if (sortResponse === response) {
            sortResponse = null
        }
    }

    @Synchronized
    fun onFilterResponse(response: List<InAppContentBlock>) {
        filterResponse?.complete(response)
    }

    @Synchronized
    fun onSortResponse(response: List<InAppContentBlock>) {
        sortResponse?.complete(response)
    }
}
